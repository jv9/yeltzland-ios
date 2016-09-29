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
import WatchKit

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
        
        NSLog("Complications updated")
    }

    // MARK:- WCSessionDelegate implementation - update local settings when transfered from phone
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
    
    @objc
    public func session(session: WCSession,
                        activationDidCompleteWithState activationState: WCSessionActivationState,
                        error: NSError?) {}
    
    @objc
    public func sessionDidBecomeInactive(session: WCSession) {}
    
    @objc
    public func sessionDidDeactivate(session: WCSession) {}
    
    private func updateSettings(userInfo: [String : AnyObject]) {
        // Update each incoming setting
        for (key, value) in userInfo {
            self.writeObjectToStore(value, key: key)
        }
        
        // Send a notification for the view controllers to refresh
        NSNotificationCenter.defaultCenter().postNotificationName(WatchGameSettings.UpdateSettingsNotification, object:nil, userInfo:nil)
        NSLog("Sent 'Update Settings' notification")
        
        // Refresh any complications
        self.updateComplications()
        
        // Also schedule a snapshot for a few seconds time
        self.scheduleSnapshot()
    }
    
    private func scheduleSnapshot() {
        // Let's update the snapshot if the view changed
        print("Scheduling snapshot")
        let soon =  NSCalendar.autoupdatingCurrentCalendar().dateByAddingUnit(.Second, value: 5, toDate: NSDate(), options: [])
        WKExtension.sharedExtension().scheduleSnapshotRefreshWithPreferredDate(soon!, userInfo: nil, scheduledCompletion: { (error: NSError?) in
            if let error = error {
                print("Error occurred while scheduling snapshot: \(error.localizedDescription)")
            }})
    }
}

