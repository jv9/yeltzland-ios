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
        
        NSLog("Complications updated")
    }

    // MARK:- Watch specific settings
    public var truncateLastOpponent: String {
        get {
            return self.truncateTeamName(self.displayLastOpponent, max:16)
        }
    }
    
    public var truncateNextOpponent: String {
        get {
            return self.truncateTeamName(self.displayNextOpponent, max:16)
        }
    }
    
    public var smallOpponent: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore, .GameDayBefore:
                return self.truncateTeamName(self.displayNextOpponent, max: 4)
            case .During, .DuringNoScore:
                return self.truncateTeamName(self.displayNextOpponent, max: 4)
            case .After:
                return self.truncateTeamName(self.displayLastOpponent, max: 4)
            case .None:
                return "None"
            }
        }
    }
    
    public var smallScoreOrDate: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore:
                // If no opponent, then no kickoff time
                if (self.nextGameTeam.characters.count == 0) {
                    return ""
                }
                
                let now = NSDate()
                let todayDayNumber = self.dayNumber(now)
                let nextGameNumber = self.dayNumber(self.nextGameTime)
                
                let formatter = NSDateFormatter()
                
                if (nextGameNumber - todayDayNumber > 7) {
                    // If next game more than a week off, show the day number
                    formatter.dateFormat = "d"
                } else {
                    // Otherwise show the day name
                    formatter.dateFormat = "E"
                }
                
                return formatter.stringFromDate(self.nextGameTime)
            case .GameDayBefore:
                // If no opponent, then no kickoff time
                if (self.nextGameTeam.characters.count == 0) {
                    return ""
                }
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = "HHmm"
                
                return formatter.stringFromDate(self.nextGameTime)
            case .During, .DuringNoScore:
                return self.currentScore
            case .After:
                return self.lastScore
            case .None:
                return ""
            }
        }
    }
    
    public var smallScore: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore, .GameDayBefore:
                return self.lastScore
            case .During, .DuringNoScore:
                return self.currentScore
            case .After:
                return self.lastScore
            case .None:
                return ""
            }
        }
    }
    
    public var longCombinedTeamScoreOrDate: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore, .GameDayBefore:
                return String(format: "%@ %@", self.truncateLastOpponent, self.lastScore)
            case .During, .DuringNoScore:
                return String(format: "%@ %@", self.truncateNextOpponent, self.currentScore)
            case .After:
                return String(format: "%@ %@", self.truncateLastOpponent, self.lastScore)
            case .None:
                return ""
            }
        }
    }
    
    public var fullTitle: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore, .GameDayBefore:
                return "Next game:"
            case .During, .DuringNoScore:
                return "Current score"
            case .After:
                return "Last game:"
            case .None:
                return ""
            }
        }
    }

    public var fullTeam: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore, .GameDayBefore:
                return self.truncateNextOpponent
            case .During, .DuringNoScore:
                return self.truncateNextOpponent
            case .After:
                return self.truncateLastOpponent
            case .None:
                return ""
            }
        }
    }

    public var fullScoreOrDate: String {
        get {
            switch self.currentGameState() {
            case .DaysBefore:
                return self.nextKickoffTime
            case .GameDayBefore:
                // If no opponent, then no kickoff time
                if (self.nextGameTeam.characters.count == 0) {
                    return ""
                }
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = "HHmm"
                let formattedTime = formatter.stringFromDate(self.nextGameTime)
                return String(format: "Today at %@", formattedTime)
            case .During, .DuringNoScore:
                return self.currentScore
            case .After:
                return self.lastScore
            case .None:
                return ""
            }
        }
    }
    
    private func truncateTeamName(original:String, max:Int) -> String {
        let originalLength = original.characters.count
        
        // If the original is short enough, we're done
        if (originalLength <= max) {
            return original
        }
        
        // Find the first space
        var firstSpace = 0
        for c in original.characters {
            if (c == Character(" ")) {
                break
            }
            firstSpace = firstSpace + 1
        }
        
        if (firstSpace < max) {
            return original[original.startIndex..<original.startIndex.advancedBy(firstSpace)]
        }
        
        // If still not found, just truncate it
        return original[original.startIndex..<original.startIndex.advancedBy(max)].stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
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
    }
}

