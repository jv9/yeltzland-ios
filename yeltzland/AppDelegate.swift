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
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

    var window: UIWindow?
    
    // Notification settings
    // See https://github.com/googlesamples/google-services/blob/master/ios/gcm/GcmExampleSwift/AppDelegate.swift
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
    let subscriptionTopic = "/topics/gametimetweets"
    
    let sandboxMode = true

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
        
        // *** Notifications registration ***
        
        // Configure the Google context: parses the GoogleService-Info.plist, and initializes
        // the services that have entries in the file
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        self.gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID

        // Register for remote notifications
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()

        // Start GCM service
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
        GCMService.sharedInstance().startWithConfig(gcmConfig)
        // ** End of notifications setup
        
        // Initial web page
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let initialTabViewController = MainTabBarController()
        self.window?.rootViewController = initialTabViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the topic
        if(self.registrationToken != nil && self.connectedToGCM) {
            GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: self.subscriptionTopic,
                                                          options: nil, handler: {(error:NSError?) -> Void in
                                                            if let error = error {
                                                                // Treat the "already subscribed" error more gently
                                                                if error.code == 3001 {
                                                                    print("Already subscribed to \(self.subscriptionTopic)")
                                                                } else {
                                                                    print("Subscription failed: \(error.localizedDescription)");
                                                                }
                                                            } else {
                                                                self.subscribedToTopic = true;
                                                                NSLog("Subscribed to \(self.subscriptionTopic)");
                                                            }
            })
        }
    }
    
    func applicationDidBecomeActive( application: UIApplication) {
        // Connect to the GCM server to receive non-APNS notifications
        GCMService.sharedInstance().connectWithHandler({(error:NSError?) -> Void in
            if let error = error {
                print("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                print("Connected to GCM")
                
                self.subscribeToTopic()
            }
        })
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        GCMService.sharedInstance().disconnect()
        self.connectedToGCM = false
    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: NSData ) {
        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        self.registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
                               kGGLInstanceIDAPNSServerTypeSandboxOption:self.sandboxMode]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(self.gcmSenderID,
                                                                 scope: kGGLInstanceIDScopeGCM, options: self.registrationOptions, handler: registrationHandler)
    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: NSError ) {
        print("Registration for remote notification failed with error: \(error.localizedDescription)")

        let userInfo = ["error": error.localizedDescription]
        NSNotificationCenter.defaultCenter().postNotificationName(
            self.registrationKey, object: nil, userInfo: userInfo)
    }
    
    func application( application: UIApplication,
                      didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Notification received: \(userInfo)")
        
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        
        // Handle the received message
        NSNotificationCenter.defaultCenter().postNotificationName(self.messageKey, object: nil,
                                                                  userInfo: userInfo)
    }
    
    func application( application: UIApplication,
                      didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                                                   fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        print("Notification received: \(userInfo)")
        
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        
        // Handle the received message
        // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        NSNotificationCenter.defaultCenter().postNotificationName(self.messageKey, object: nil,
                                                                  userInfo: userInfo)
        
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
        
        handler(UIBackgroundFetchResult.NoData);
    }
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            print("Registration Token: \(registrationToken)")
            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        }
    }
    
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(self.gcmSenderID,
                                                                 scope: kGGLInstanceIDScopeGCM, options: self.registrationOptions, handler: registrationHandler)
    }
}

