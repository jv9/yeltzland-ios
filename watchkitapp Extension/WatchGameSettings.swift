//
//  WatchGameSettings.swift
//  yeltzland
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import WatchConnectivity
import ClockKit

public class WatchGameSettings : BaseSettings, WCSessionDelegate {
    
    public static let UpdateSettingsNotification = "kYTZUserSettingsNotification"

    
    func initialiseWatchSession() {
        if (self.watchSessionInitialised) {
            NSLog("Watch session already initialised")
            return
        }
        
        self.watchSessionInitialised = true
        NSLog("Watch session starting initialisation...")
        
        // Set up watch setting if appropriate
        if (WCSession.isSupported()) {
            NSLog("Setting up watch session ...")
            let session: WCSession = WCSession.defaultSession();
            session.delegate = self
            session.activateSession()
            NSLog("Watch session activated")
        } else {
            NSLog("No watch session set up")
        }
    }
    
    public func updateComplications() {
        NSLog("Updating complications...")
        let complicationServer = CLKComplicationServer.sharedInstance()
        let activeComplications = complicationServer.activeComplications
        
        if (activeComplications != nil) {
            for complication in activeComplications! {
                complicationServer.reloadTimelineForComplication(complication)
            }
        }
    }

    /// WCSessionDelegate implementation - update local settings when transfered from phone
    @objc
    public func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        NSLog("New user info transfer data received on watch")
        self.updateSettings(userInfo)
    }
    
    @objc
    public func session(session: WCSession, didReceiveUpdate receivedApplicationContext: [String : AnyObject]) {
        NSLog("New context transfer data received on watch")
        self.updateSettings(receivedApplicationContext)
    }
    
    private func updateSettings(userInfo: [String : AnyObject]) {
        // Update each incoming setting
        for (key, value) in userInfo {
            self.writeObjectToStore(value, key: key)
        }
        
        // Send a notification for the view controllers to refresh
        NSNotificationCenter.defaultCenter().postNotificationName(WatchGameSettings.UpdateSettingsNotification, object:nil, userInfo:nil)
        NSLog("Sent UpdateSettingsNotification")
        
        // Refresh any complications
        self.updateComplications()
    }
}

