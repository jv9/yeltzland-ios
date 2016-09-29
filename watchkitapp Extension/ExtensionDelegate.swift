//
//  ExtensionDelegate.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    var model:WatchGameSettings = WatchGameSettings()
    
    override init() {
        super.init()
        self.setupNotificationWatchers()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("Removed notification handler in watch extension delegate")
    }
    
    private func setupNotificationWatchers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ExtensionDelegate.settingsUpdated), name: BaseSettings.SettingsUpdateNotification, object: nil)
        print("Setup notification handlers for fixture or score updates in watch game settings")
    }

    func applicationDidBecomeActive() {
        self.model.initialiseWatchSession()
        
        // Go and fetch the latest data
        FixtureManager.instance.getLatestFixtures()
        GameScoreManager.instance.getLatestGameScore()
    }
    
    func handleBackgroundTasks(backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("Handling background task started")
        
        // Mark tasks as completed
        for task in backgroundTasks {
            // TODO: Do something on background task perhaps?
            task.setTaskCompleted()
            print("Handled background task \(task)")
        }
        
        print("Handling background task ended")
    }
    
    func settingsUpdated() {
        // Update complications
        NSLog("Updating complications...")
        let complicationServer = CLKComplicationServer.sharedInstance()
        let activeComplications = complicationServer.activeComplications
        
        if (activeComplications != nil) {
            for complication in activeComplications! {
                complicationServer.reloadTimelineForComplication(complication)
            }
        }
        
        NSLog("Complications updated")
        
        // Schedule snapshot
        print("Scheduling snapshot")
        let soon =  NSCalendar.autoupdatingCurrentCalendar().dateByAddingUnit(.Second, value: 5, toDate: NSDate(), options: [])
        WKExtension.sharedExtension().scheduleSnapshotRefreshWithPreferredDate(soon!, userInfo: nil, scheduledCompletion: { (error: NSError?) in
            if let error = error {
                print("Error occurred while scheduling snapshot: \(error.localizedDescription)")
            }})
        print("Snapshot scheduled")
    }
}
