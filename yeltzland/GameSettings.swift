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
        
        let lastGame = FixtureManager.instance.getLastGame()
        
        if (lastGame == nil) {
            self.lastGameTeam = ""
            self.lastGameYeltzScore = 0
            self.lastGameOpponentScore = 0
            self.lastGameHome = false
        } else {
            self.lastGameTime = lastGame!.fixtureDate
            self.lastGameTeam = lastGame!.opponent
            self.lastGameYeltzScore = lastGame!.teamScore!
            self.lastGameOpponentScore = lastGame!.opponentScore!
            self.lastGameHome = lastGame!.home
        }
        
        let nextGame = FixtureManager.instance.getNextGame()
        
        if (nextGame == nil) {
            self.nextGameTeam = ""
            self.nextGameHome = false
        } else {
            self.nextGameTime = nextGame!.fixtureDate
            self.nextGameTeam = nextGame!.opponent
            self.nextGameHome = nextGame!.home
        }
        
        self.pushAllSettingsToWatch()
    }
    
    public func refreshGameScore() {
        NSLog("Updating game score settings ...")
        
        if let scoreMatchDate = GameScoreManager.instance.MatchDate {
            self.currentGameTime = scoreMatchDate
            self.currentGameYeltzScore = GameScoreManager.instance.YeltzScore
            self.currentGameOpponentScore = GameScoreManager.instance.OpponentScore
            
            self.pushAllSettingsToWatch()
        }
    }
    
    /// Send initial settings to watch
    private func pushAllSettingsToWatch() {
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
            
            do {
                try session.updateApplicationContext(updatedSettings)
                print("Settings pushed to watch")
            }
            catch {
                NSLog("An error occurred pushing settings to watch: \(error)")
            }
        }
    }
}
