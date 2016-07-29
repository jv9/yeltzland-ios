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
    
    @IBOutlet var topHeadingLabel: WKInterfaceLabel!
    @IBOutlet var bottomHeadingLabel: WKInterfaceLabel!
    
    @IBOutlet var topTeamLabel: WKInterfaceLabel!
    @IBOutlet var topScoreLabel: WKInterfaceLabel!
    
    @IBOutlet var bottomTeamLabel: WKInterfaceLabel!
    @IBOutlet var bottomScoreLabel: WKInterfaceLabel!
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InterfaceController.userSettingsUpdated(_:)), name: WatchGameSettings.UpdateSettingsNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.updateViewData()
    }

    override func willActivate() {
        super.willActivate()
        self.setTitle("Yeltzland")
        
        self.updateViewData()
    }
    
    private func updateViewData() {
        NSLog("Updating view data...")
        
        let appDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        let gameSettings = appDelegate.model
    
        // Setup colors
        self.topHeadingLabel.setTextColor(AppColors.WatchHeadingColor)
        self.bottomHeadingLabel.setTextColor(AppColors.WatchHeadingColor)
        
        self.topTeamLabel.setTextColor(AppColors.WatchTextColor)
        
        if (gameSettings.lastGameYeltzScore > gameSettings.lastGameOpponentScore) {
            self.topScoreLabel.setTextColor(AppColors.WatchFixtureWin)
        } else if (gameSettings.lastGameYeltzScore == gameSettings.lastGameOpponentScore) {
            self.topScoreLabel.setTextColor(AppColors.WatchFixtureDraw)
        } else if (gameSettings.lastGameYeltzScore < gameSettings.lastGameOpponentScore) {
            self.topScoreLabel.setTextColor(AppColors.WatchFixtureLose)
        }
        
        self.bottomTeamLabel.setTextColor(AppColors.WatchTextColor)
        self.bottomScoreLabel.setTextColor(AppColors.WatchTextColor)
        
        // Set label text
        self.topHeadingLabel.setText("Last game:")
        self.topTeamLabel.setText(gameSettings.displayLastOpponent)
        self.topScoreLabel.setText(gameSettings.lastScore)
        
        // Do we have a current score?
        if (gameSettings.gameScoreForCurrentGame) {
            self.bottomHeadingLabel.setText("Current game:")
            self.bottomScoreLabel.setText(gameSettings.currentScore)
        } else {
            self.bottomHeadingLabel.setText("Next game:")
            self.bottomScoreLabel.setText(gameSettings.nextKickoffTime)
        }
        
        self.bottomTeamLabel.setText(gameSettings.displayNextOpponent)

        NSLog("View updated")
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
