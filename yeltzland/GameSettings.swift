//
//  GameSettings.swift
//  yeltzland
//
//  Created by John Pollard on 28/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity

public class GameSettings : BaseSettings, WCSessionDelegate {

    private static let sharedInstance = GameSettings()
    class var instance:GameSettings {
        get {
            return sharedInstance
        }
    }

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
    
    public func refreshFixtures() {
        NSLog("Updating game fixture settings ...")
        
        var updated = false
        var lastGameTeam = ""
        var lastGameYeltzScore = 0
        var lastGameOpponentScore = 0
        var lastGameHome = false
        var lastGameTime:NSDate? = nil
        
        let currentlyInGame = self.currentGameState() == GameState.During
        
        if let lastGame = FixtureManager.instance.getLastGame() {
            lastGameTime = lastGame.fixtureDate
            lastGameTeam = lastGame.opponent
            lastGameYeltzScore = lastGame.teamScore!
            lastGameOpponentScore = lastGame.opponentScore!
            lastGameHome = lastGame.home
        }
        
        if (lastGameTime != nil && self.lastGameTime.compare(lastGameTime!) != NSComparisonResult.OrderedSame) {
            self.lastGameTime = lastGameTime!
            updated = true
        }
        
        if (self.lastGameTeam != lastGameTeam) {
            self.lastGameTeam = lastGameTeam
            updated = true
        }
        
        if (self.lastGameYeltzScore != lastGameYeltzScore) {
            self.lastGameYeltzScore = lastGameYeltzScore
            updated = true
        }
        
        if (self.lastGameOpponentScore != lastGameOpponentScore) {
            self.lastGameOpponentScore = lastGameOpponentScore
            updated = true
        }
        
        if (self.lastGameHome != lastGameHome) {
            self.lastGameHome = lastGameHome
            updated = true
        }
        
        
        var nextGameTeam = ""
        var nextGameHome = false
        var nextGameTime:NSDate? = nil
        
        if let nextGame = FixtureManager.instance.getNextGame() {
            nextGameTime = nextGame.fixtureDate
            nextGameTeam = nextGame.opponent
            nextGameHome = nextGame.home
        }

        if (nextGameTime != nil && self.nextGameTime.compare(nextGameTime!) != NSComparisonResult.OrderedSame) {
            self.nextGameTime = nextGameTime!
            updated = true
        }
        
        if (self.nextGameTeam != nextGameTeam) {
            self.nextGameTeam = nextGameTeam
            updated = true
        }
        
        if (self.nextGameHome != nextGameHome) {
            self.nextGameHome = nextGameHome
            updated = true
        }

        // If any values have been changed, push then to the watch
        if (updated) {
            self.pushAllSettingsToWatch(currentlyInGame)
        } else {
            NSLog("No fixture settings changed")
        }
    }
    
    public func refreshGameScore() {
        NSLog("Updating game score settings ...")
        
        let currentlyInGame = self.currentGameState() == GameState.During
        
        if let currentGameTime = GameScoreManager.instance.MatchDate {
            var updated = false
            
            let currentGameYeltzScore = GameScoreManager.instance.YeltzScore
            let currentGameOpponentScore = GameScoreManager.instance.OpponentScore
            
            if (self.currentGameTime.compare(currentGameTime) != NSComparisonResult.OrderedSame) {
                self.currentGameTime = currentGameTime
                updated = true
            }
            
            if (self.currentGameYeltzScore != currentGameYeltzScore) {
                self.currentGameYeltzScore = currentGameYeltzScore
                updated = true
            }
            
            if (self.currentGameOpponentScore != currentGameOpponentScore) {
                self.currentGameOpponentScore = currentGameOpponentScore
                updated = true
            }
            
            // If any values have been changed, push then to the watch
            if (updated) {
                self.pushAllSettingsToWatch(currentlyInGame)
            } else {
                NSLog("No game settings changed")
            }
        }
    }
    
    // Update the watch in background
    public func forceBackgroundWatchUpdate() {
        self.pushAllSettingsToWatch(false)
    }
    
    /// Send initial settings to watch
    private func pushAllSettingsToWatch(currentlyInGame:Bool) {
        self.initialiseWatchSession()
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            
            var updatedSettings = Dictionary<String, AnyObject>()
            updatedSettings["lastGameTime"] = self.lastGameTime
            updatedSettings["lastGameTeam"] = self.lastGameTeam
            updatedSettings["lastGameYeltzScore"] = self.lastGameYeltzScore
            updatedSettings["lastGameOpponentScore"] = self.lastGameOpponentScore
            updatedSettings["lastGameHome"] = self.lastGameHome
            
            updatedSettings["nextGameTime"] = self.nextGameTime
            updatedSettings["nextGameTeam"] = self.nextGameTeam
            updatedSettings["nextGameHome"] = self.nextGameHome
            
            updatedSettings["currentGameTime"] = self.currentGameTime
            updatedSettings["currentGameYeltzScore"] = self.currentGameYeltzScore
            updatedSettings["currentGameOpponentScore"] = self.currentGameOpponentScore
            
            // If we're in a game, push it out straight away, otherwise do it in the background
            if (currentlyInGame) {
                session.transferCurrentComplicationUserInfo(updatedSettings)
            } else {
                session.transferUserInfo(updatedSettings)
            }
            
            NSLog("Settings pushed to watch")
        }
    }
}
