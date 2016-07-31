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
}
