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
    
    func applicationDidBecomeActive() {
        self.model.initialiseWatchSession()
        self.model.updateComplications()
    }
    
    func handleBackgroundTasks(backgroundTasks: Set<WKRefreshBackgroundTask>) {
        print("Handling background task started")
        
        // Mark tasks as completed
        for task in backgroundTasks {
            // TODO: Do something on background task perhaps?
            task.setTaskCompleted()
        }
    }

}
