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
        Fabric.with([Crashlytics.self, Twitter.self])
        
        // Setup notifications
        self.azureNotifications.setupNotifications(false)
        
        // Initial web page
        var firstTab = 0;
        if launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] != nil {
            // If came from a notification, start on the Twitter tab
            firstTab = 3
        }
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let initialTabViewController = MainTabBarController(initialTab:firstTab)
        self.window?.rootViewController = initialTabViewController
        self.window?.makeKeyAndVisible()
        
        return true
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

