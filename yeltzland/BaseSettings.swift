//
//  BaseSettings.swift
//  yeltzland
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import WatchConnectivity

public class BaseSettings : NSObject {
    
    var appStandardUserDefaults: NSUserDefaults?
    var watchSessionInitialised: Bool = false
    
    public init(defaultPreferencesName: String = "DefaultPreferences", suiteName: String = "group.bravelocation.yeltzland") {
        super.init()
        
        // Setup the default preferences
        let defaultPrefsFile: NSURL? = NSBundle.mainBundle().URLForResource(defaultPreferencesName, withExtension: "plist")
        let defaultPrefs: NSDictionary? = NSDictionary(contentsOfURL:defaultPrefsFile!)
        
        self.appStandardUserDefaults = NSUserDefaults(suiteName: suiteName)!
        self.appStandardUserDefaults!.registerDefaults(defaultPrefs as! [String: AnyObject]);
        
        // Migrate old settings if required
        self.migrateSettingsToGroup()
    }
    
    public var gameTimeTweetsEnabled: Bool {
        get { return self.readObjectFromStore("GameTimeTweetsEnabled") as! Bool }
        set { self.writeObjectToStore(newValue, key: "GameTimeTweetsEnabled") }
    }
    
    public var lastSelectedTab: Int {
        get { return self.readObjectFromStore("LastSelectedTab") as! Int }
        set { self.writeObjectToStore(newValue, key: "LastSelectedTab") }
    }
    
    public var lastGameTime: NSDate {
        get { return self.readObjectFromStore("lastGameTime") as! NSDate }
        set { self.writeObjectToStore(newValue, key: "lastGameTime") }
    }
    
    public var lastGameTeam: String {
        get { return self.readObjectFromStore("lastGameTeam") as! String }
        set { self.writeObjectToStore(newValue, key: "lastGameTeam") }
    }
    
    public var lastGameYeltzScore: Int {
        get { return self.readObjectFromStore("lastGameYeltzScore") as! Int }
        set { self.writeObjectToStore(newValue, key: "lastGameYeltzScore") }
    }
    
    public var lastGameOpponentScore: Int {
        get { return self.readObjectFromStore("lastGameOpponentScore") as! Int }
        set { self.writeObjectToStore(newValue, key: "lastGameOpponentScore") }
    }
    
    public var lastGameHome: Bool {
        get { return self.readObjectFromStore("lastGameHome") as! Bool }
        set { self.writeObjectToStore(newValue, key: "lastGameHome") }
    }
    
    public var nextGameTime: NSDate {
        get { return self.readObjectFromStore("nextGameTime") as! NSDate }
        set { self.writeObjectToStore(newValue, key: "nextGameTime") }
    }
    
    public var nextGameTeam: String {
        get { return self.readObjectFromStore("nextGameTeam") as! String }
        set { self.writeObjectToStore(newValue, key: "nextGameTeam") }
    }
    
    public var nextGameHome: Bool {
        get { return self.readObjectFromStore("nextGameHome") as! Bool }
        set { self.writeObjectToStore(newValue, key: "nextGameHome") }
    }
    
    public var currentGameTime: NSDate {
        get { return self.readObjectFromStore("currentGameTime") as! NSDate }
        set { self.writeObjectToStore(newValue, key: "currentGameTime") }
    }
    
    public var currentGameYeltzScore: Int {
        get { return self.readObjectFromStore("currentGameYeltzScore") as! Int }
        set { self.writeObjectToStore(newValue, key: "currentGameYeltzScore") }
    }
    
    public var currentGameOpponentScore: Int {
        get { return self.readObjectFromStore("currentGameOpponentScore") as! Int }
        set { self.writeObjectToStore(newValue, key: "currentGameOpponentScore") }
    }
    
    public var migratedToGroupSettings: Bool {
        get { return self.readObjectFromStore("migratedToGroupSettings") as! Bool }
        set { self.writeObjectToStore(newValue, key: "migratedToGroupSettings") }
    }
    
    public var displayLastOpponent: String {
        get {
            return self.lastGameHome ? self.lastGameTeam.uppercaseString : self.lastGameTeam
        }
    }
    
    public var displayNextOpponent: String {
        get {
            return self.nextGameHome ? self.nextGameTeam.uppercaseString : self.nextGameTeam
        }
    }
    
    public var truncateLastOpponent: String {
        get {
            return self.truncateTeamName(self.displayLastOpponent)
        }
    }
    
    public var truncateNextOpponent: String {
        get {
            return self.truncateTeamName(self.displayNextOpponent)
        }
    }
    
    public var lastScore: String {
        get {
            // If no opponent, then no score
            if (self.lastGameTeam.characters.count == 0) {
                return ""
            }
            
            var result = ""
            if (self.lastGameYeltzScore > self.lastGameOpponentScore) {
                result = "W"
            } else if (self.lastGameYeltzScore < self.lastGameOpponentScore) {
                result = "L"
            } else {
                result = "D"
            }
            
            return String.init(format: "%@ %d-%d", result, self.lastGameYeltzScore, self.lastGameOpponentScore)
        }
    }
    
    public var currentScore: String {
        get {
            // If no opponent, then no current score
            if (self.nextGameTeam.characters.count == 0) {
                return ""
            }
            
            return String.init(format: "%d-%d*", self.currentGameYeltzScore, self.currentGameOpponentScore)
        }
    }
    
    public var nextKickoffTime: String {
        get {
            // If no opponent, then no kickoff time
            if (self.nextGameTeam.characters.count == 0) {
                return ""
            }
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE d MMM"
            
            return formatter.stringFromDate(self.nextGameTime)
        }
    }
 
    public var nextKickoffTimeShort: String {
        get {
            // If no opponent, then no kickoff time
            if (self.nextGameTeam.characters.count == 0) {
                return ""
            }
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "d"
            
            return formatter.stringFromDate(self.nextGameTime)
        }
    }
    
    public var gameScoreForCurrentGame: Bool {
        get {
            // If no opponent, then no current game
            if (self.nextGameTeam.characters.count == 0) {
                return false
            }
            
            return self.nextGameTime.compare(self.currentGameTime) != NSComparisonResult.OrderedSame
        }
    }
    
    func initialiseWatchSession() {
        if (self.watchSessionInitialised) {
            NSLog("Watch session already initialised")
            return
        }
        
        self.watchSessionInitialised = true
        
        // Set up watch setting if appropriate
        if (WCSession.isSupported()) {
            NSLog("Setting up watch session ...")
            let session: WCSession = WCSession.defaultSession();
            session.activateSession()
            NSLog("Watch session activated")
        } else {
            NSLog("No watch session set up")
        }
    }
    
    func readObjectFromStore(key: String) -> AnyObject?{
        // Otherwise try the user details
        let userSettingsValue = self.appStandardUserDefaults!.valueForKey(key)
        
        return userSettingsValue
    }
    
    func writeObjectToStore(value: AnyObject, key: String) {
        // Write to local user settings
        self.appStandardUserDefaults!.setObject(value, forKey:key)
        self.appStandardUserDefaults!.synchronize()
    }
    
    private func migrateSettingsToGroup() {
        if (self.migratedToGroupSettings) {
            return
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        self.lastSelectedTab = defaults.integerForKey("LastSelectedTab")
        self.gameTimeTweetsEnabled = defaults.boolForKey("GameTimeTweetsEnabled")
        self.migratedToGroupSettings = true
        
        NSLog("Migrated settings to group")
    }
    
    private func truncateTeamName(original:String) -> String {
        let max = 16;
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
}
