//
//  AzureNotifications.swift
//  yeltzland
//
//  Created by John Pollard on 23/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit

public class AzureNotifications {
    #if DEBUG
        let hubName = "yeltzlandiospushsandbox"
        let hubListenAccess = "Endpoint=sb://yeltzlandiospushsandbox.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=l+/LW0kWPo/XgZGKj78do/AyAxpEEUhLuORhyBRMgzM="
    #else
        let hubName = "yeltzlandiospush"
        let hubListenAccess = "Endpoint=sb://yeltzlandiospush.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=A8Lb23v0p0gI8KO2Vh6mjN6Qqe621Pwu8C8k5S8u7hQ="
    #endif
    
    var tagNames:Set<NSObject> = []
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
    
    init() {
        self.tagNames = ["gametimealerts"]
        #if DEBUG
            self.tagNames = ["gametimealerts", "testtag"]
        #endif
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
        
        // Debug device token:
        var token = deviceToken.description
        token = token.stringByReplacingOccurrencesOfString("<", withString: "")
        token = token.stringByReplacingOccurrencesOfString(">", withString: "")
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        print("Device token: \(token)")
        
        if (self.enabled) {
            do {
                try hub.registerNativeWithDeviceToken(deviceToken, tags: self.tagNames)
                print("Registered with hub: \(self.tagNames)")
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
