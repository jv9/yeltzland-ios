//
//  AppDelegate.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit
import Whisper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let azureNotifications = AzureNotifications()
    let LASTSELECTEDTABSETTING = "LastSelectedTab"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Nav bar colors
        UINavigationBar.appearance().barTintColor = AppColors.NavBarColor;

        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: AppColors.NavBarTextColor,
            NSFontAttributeName: UIFont(name: AppColors.AppFontName, size: AppColors.NavBarTextSize)!
        ]
        
        // Tab bar font
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: AppColors.AppFontName, size: AppColors.TabBarTextSize)!
        ], forState: .Normal)
        
        // Setup Fabric
        #if DEBUG
            Fabric.with([Twitter.self])
        #else
            Fabric.with([Crashlytics.self, Twitter.self])
        #endif
        
        // Setup notifications
        self.azureNotifications.setupNotifications(false)
        
        // Update the fixture and scores cache
        FixtureManager.instance.getLatestFixtures()
        
        // If came from a notification, always start on the Twitter tab
        if launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] != nil {
            NSUserDefaults.standardUserDefaults().setInteger(3, forKey: self.LASTSELECTEDTABSETTING)
        } else if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] {
            self.handleShortcut(shortcutItem as! UIApplicationShortcutItem)
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let initialTabViewController = MainTabBarController()
        self.window?.rootViewController = initialTabViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        NSLog("3D Touch when from shortcut action");
        let handledShortCut = self.handleShortcut(shortcutItem)
        
        // Reset selected tab
        let mainViewController: MainTabBarController? = self.window?.rootViewController as? MainTabBarController
        if (mainViewController != nil) {
            mainViewController!.selectedIndex = NSUserDefaults.standardUserDefaults().integerForKey(self.LASTSELECTEDTABSETTING)
        }
        
        return completionHandler(handledShortCut);
    }
    
    func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        NSLog("Handling shortcut item %@", shortcutItem.type);
        
        if (shortcutItem.type == "com.bravelocation.yeltzland.forum") {
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: self.LASTSELECTEDTABSETTING)
            return true
        }
        
        if (shortcutItem.type == "com.bravelocation.yeltzland.official") {
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: self.LASTSELECTEDTABSETTING)
            return true
        }
        
        if (shortcutItem.type == "com.bravelocation.yeltzland.yeltztv") {
            NSUserDefaults.standardUserDefaults().setInteger(2, forKey: self.LASTSELECTEDTABSETTING)
            return true
        }
        
        if (shortcutItem.type == "com.bravelocation.yeltzland.twitter") {
            NSUserDefaults.standardUserDefaults().setInteger(3, forKey: self.LASTSELECTEDTABSETTING)
            return true
        }
        
        return false
    }
 
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.azureNotifications.register(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Device token for push notifications: FAIL -- ")
        print(error.description)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        self.messageReceived(application, userInfo: userInfo)
    }
    
    func application(application: UIApplication,
                      didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                                                   fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        self.messageReceived(application, userInfo: userInfo)
        handler(UIBackgroundFetchResult.NoData);
    }
    
    func messageReceived(application: UIApplication,
                         userInfo: [NSObject : AnyObject]) {
        // Print message
        print("Notification received: \(userInfo)")
        
        // If app in foreground, show a whisper
        if (application.applicationState == .Active) {
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSDictionary {
                    if let body = alert["body"] as? NSString {
                        let message = Message(title: body as String, backgroundColor: AppColors.ActiveAlertBackground, textColor: AppColors.ActiveAlertText)
                        
                        // Show and hide a message after delay
                        if (self.window != nil && self.window?.rootViewController != nil) {
                            if let tabController : UITabBarController? = (self.window?.rootViewController as! UITabBarController) {
                                if let navigationController : UINavigationController? = tabController!.viewControllers![0] as? UINavigationController {
                                    Whisper(message, to: navigationController!, action: .Show)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

