//
//  InterfaceController.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var topTeamLabel: WKInterfaceLabel!
    @IBOutlet var topScoreLabel: WKInterfaceLabel!
    
    @IBOutlet var bottomTeamLabel: WKInterfaceLabel!
    @IBOutlet var bottomScoreLabel: WKInterfaceLabel!
    
    @IBOutlet var footnoteLabel: WKInterfaceLabel!
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InterfaceController.userSettingsUpdated(_:)), name: BaseSettings.SettingsUpdateNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func willActivate() {
        super.willActivate()
        self.setTitle("Yeltzland")
        
        self.updateViewData()
    }
    
    private func updateViewData() {
        let appDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        let gameSettings = appDelegate.model
    
        // Setup colors
        self.topTeamLabel.setTextColor(AppColors.WatchTextColor)
        self.bottomTeamLabel.setTextColor(AppColors.WatchTextColor)
        self.bottomScoreLabel.setTextColor(AppColors.WatchTextColor)
        
        if (gameSettings.lastGameYeltzScore > gameSettings.lastGameOpponentScore) {
            self.topScoreLabel.setTextColor(AppColors.WatchFixtureWin)
        } else if (gameSettings.lastGameYeltzScore == gameSettings.lastGameOpponentScore) {
            self.topScoreLabel.setTextColor(AppColors.WatchFixtureDraw)
        } else if (gameSettings.lastGameYeltzScore < gameSettings.lastGameOpponentScore) {
            self.topScoreLabel.setTextColor(AppColors.WatchFixtureLose)
        }
        
        // Set label text
        self.topTeamLabel.setText(gameSettings.truncateLastOpponent)
        self.topScoreLabel.setText(gameSettings.lastScore)
        self.bottomTeamLabel.setText(gameSettings.truncateNextOpponent)
        
        // Do we have a current score?
        if (gameSettings.gameScoreForCurrentGame) {
            self.bottomScoreLabel.setText(gameSettings.currentScore)
            self.footnoteLabel.setText("(*best guess from Twitter)")
        } else {
            self.bottomScoreLabel.setText(gameSettings.nextKickoffTime)
            self.footnoteLabel.setText("")
        }
    }
    
    @objc
    private func userSettingsUpdated(notification: NSNotification) {
        NSLog("Received Settings updated notification")
        
        // Update view data on main thread
        dispatch_async(dispatch_get_main_queue()) {
            self.updateViewData()
        }
    }
   
}
