//
//  ExtensionDelegate.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    lazy var model:WatchGameSettings = WatchGameSettings()
    
    func applicationDidBecomeActive() {
        NSLog("applicationDidBecomeActive started")
        self.model.initialiseWatchSession()
        NSLog("applicationDidBecomeActive completed")
    }
}
