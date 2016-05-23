//
//  AzureNotifications.swift
//  yeltzland
//
//  Created by John Pollard on 23/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit

public class AzureNotifications {
    let hubName = "yeltzlandiospush"
    let hubListenAccess = "Endpoint=sb://yeltzlandiospush.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=A8Lb23v0p0gI8KO2Vh6mjN6Qqe621Pwu8C8k5S8u7hQ="
    let tagNames:Set<NSObject> = ["gametimealerts"]
    let defaults = NSUserDefaults.standardUserDefaults()

    var enabled: Bool {
        get {
            return self.defaults.boolForKey("GameTimeTweetsEnabled")
        }
        set(newValue) {
            // If changed, set the value and re-register
            let currentValue = self.enabled
            
            if (newValue != currentValue) {
                self.defaults.setBool(newValue, forKey: "GameTimeTweetsEnabled")
                self.setupNotifications(true)
            }
        }
    }
    
    func setupNotifications(forceSetup: Bool) {
        if (forceSetup || self.enabled) {
            let application = UIApplication.sharedApplication()

            let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    func register(deviceToken: NSData) {
        // Register with Azure Hub
        let hub = SBNotificationHub(connectionString: self.hubListenAccess, notificationHubPath: self.hubName)
        
        if (self.enabled) {
            do {
                try hub.registerNativeWithDeviceToken(deviceToken, tags: self.tagNames)
                print("Registered with hub")
            }
            catch {
                print("Error registering with hub")
            }
        } else {
            do {
                try hub.unregisterAllWithDeviceToken(deviceToken)
                print("Unregistered with hub")
            }
            catch {
                print("Error unregistering with hub")
            }
        }
    }
}
