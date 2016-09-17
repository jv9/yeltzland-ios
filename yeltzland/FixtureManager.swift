//
//  FixtureManager.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

public class FixtureManager {
    public static let FixturesNotification:String = "YLZFixtureNotification"
    private var fixtureList:[String:[Fixture]] = [String:[Fixture]]()
    
    private static let sharedInstance = FixtureManager()
    class var instance:FixtureManager {
        get {
            return sharedInstance
        }
    }
    
    public var Months: [String] {
        return Array(self.fixtureList.keys).sort()
    }
    
    public func FixturesForMonth(monthKey: String) -> [Fixture]? {
        return self.fixtureList[monthKey]
    }
    
    init() {
        // Setup local data
        self.moveSingleBundleFileToAppDirectory("matches", fileType: "json")
        
        let data:NSData? = NSData.init(contentsOfFile: self.appDirectoryFilePath("matches", fileType: "json"))
        
        if (data == nil) {
            NSLog("Couldn't load fixtures from cache")
            return
        }
        
        do {
            NSLog("Loading fixtures from cache ...")
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String : AnyObject]
            
            if (json == nil) {
                NSLog("Couldn't parse fixtures from cache")
                return
            }
            
            self.parseMatchesJson(json!)
            NSLog("Loaded fixtures from cache")
        } catch {
            NSLog("Error loading fixtures from cache ...")
            print(error)
        }
    }
    
    public func getLatestFixtures() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            NSLog("Loading fixtures from server ...")
            let dataUrl = NSURL(string: "http://yeltz.co.uk/fantasyisland/matches.json.php")!
            let serverData:NSData? = NSData.init(contentsOfURL: dataUrl)
            
            if (serverData == nil) {
                NSLog("Couldn't download fixtures from server")
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(serverData!, options: NSJSONReadingOptions()) as? [String : AnyObject]
                
                if (json == nil) {
                    NSLog("Couldn't parse fixtures from server")
                    return
                }
                
                self.parseMatchesJson(json!)
                
                // Fetch went OK, so write to local file for next startup
                if (self.Months.count > 0) {
                    NSLog("Saving server fixtures to cache")
                    
                    try serverData?.writeToFile(self.appDirectoryFilePath("matches", fileType: "json"), options: .DataWritingAtomic)
                }
                
                NSLog("Loaded fixtures from server")
                
                // Update game settings
                GameSettings.instance.refreshFixtures()
            } catch {
                NSLog("Error loading fixtures from server ...")
                print(error)
            }
        }
    }
    
    public func getAwayGames(opponent:String) -> [Fixture] {
        var foundGames:[Fixture] = []
        
        for month in self.Months {
            for fixture in self.FixturesForMonth(month)! {
                if (fixture.opponent == opponent && fixture.home == false) {
                    foundGames.append(fixture)
                }
            }
        }
        
        return foundGames
    }
    
    public func getLastGame() -> Fixture? {
        var lastCompletedGame:Fixture? = nil
        
        for month in self.Months {
            for fixture in self.FixturesForMonth(month)! {
                if (fixture.teamScore != nil && fixture.opponentScore != nil) {
                    lastCompletedGame = fixture
                } else {
                    return lastCompletedGame
                }
            }
        }
        
        return lastCompletedGame;
    }
    
    
    public func getNextGame() -> Fixture? {
        let currentDayNumber = self.dayNumber(NSDate())
        
        for month in self.Months {
            for fixture in self.FixturesForMonth(month)! {
                let matchDayNumber = self.dayNumber(fixture.fixtureDate)
                
                // If no score and match is not before today
                if (fixture.teamScore == nil && fixture.opponentScore == nil && currentDayNumber <= matchDayNumber) {
                    return fixture
                }
            }
        }
        
        return nil;
    }
    
    public func getCurrentGame() -> Fixture? {
        let nextGame = self.getNextGame()
        
        if (nextGame != nil) {
            // If within 120 minutes of kickoff date, the game is current
            let now = NSDate()
            let differenceInMinutes = NSCalendar.currentCalendar().components(.Minute, fromDate: nextGame!.fixtureDate, toDate: now, options: []).minute
            
            if (differenceInMinutes >= 0 && differenceInMinutes < 120) {
                return nextGame
            }
        }
        
        return nil
    }
    
    private func parseMatchesJson(json:[String:AnyObject]) {
        guard let matches = json["Matches"] as? Array<AnyObject> else { return }
        
        // Open lock on fixtures
        objc_sync_enter(self.fixtureList)
        
        self.fixtureList.removeAll()
        
        for currentMatch in matches {
            if let match = currentMatch as? [String:AnyObject] {
                if let currentFixture = Fixture(fromJson: match) {
                    let monthFixtures = self.FixturesForMonth(currentFixture.monthKey)
                
                    if monthFixtures != nil {
                        self.fixtureList[currentFixture.monthKey]?.append(currentFixture)
                    } else {
                        self.fixtureList[currentFixture.monthKey] = [currentFixture]
                    }
                }
            }
        }
        
        // Sort the fixtures per month
        for currentMonth in Array(self.fixtureList.keys) {
            self.fixtureList[currentMonth] = self.fixtureList[currentMonth]?.sort({ $0.fixtureDate.compare($1.fixtureDate) == .OrderedAscending })
        }
        
        // Release lock on fixtures
        objc_sync_exit(self.fixtureList)

        
        // Post notification message
        NSNotificationCenter.defaultCenter().postNotificationName(FixtureManager.FixturesNotification, object: nil)
    }
    
    private func moveSingleBundleFileToAppDirectory(fileName:String, fileType:String) {
        if (self.checkAppDirectoryExists(fileName, fileType:fileType))
        {
            // If file already exists, return
            //return
        }
        
        let fileManager = NSFileManager.defaultManager()
        let bundlePath = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)!
        if fileManager.fileExistsAtPath(bundlePath) == false {
            // No bundle file exists
            return
        }
        
        // Finally, copy the bundle file
        do {
            try fileManager.copyItemAtPath(bundlePath, toPath: self.appDirectoryFilePath(fileName, fileType: fileType))
        }
        catch {
            return
        }
    }
    
    private func appDirectoryFilePath(fileName:String, fileType:String) -> String {
        let appDirectoryPath = self.applicationDirectory()?.path
        let filePath = String.init(format: "%@.%@", fileName, fileType)
        return (appDirectoryPath?.stringByAppendingString(filePath))!
    }
    
    private func checkAppDirectoryExists(fileName:String, fileType:String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        
        return fileManager.fileExistsAtPath(self.appDirectoryFilePath(fileName, fileType:fileType))
    }
    
    private func applicationDirectory() -> NSURL? {
        let bundleId = NSBundle.mainBundle().bundleIdentifier
        let fileManager = NSFileManager.defaultManager()
        var dirPath: NSURL? = nil
        
        // Find the application support directory in the home directory.
        let appSupportDir = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        if (appSupportDir.count > 0) {
            // Append the bundle ID to the URL for the Application Support directory
            dirPath = appSupportDir[0].URLByAppendingPathComponent(bundleId!, isDirectory: true)
            
            do {
                try fileManager.createDirectoryAtURL(dirPath!, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                return nil
            }
        }
        
        return dirPath
    }
    
    private func dayNumber(date:NSDate) -> Int {
        // Removes the time components from a date
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Day, .Month, .Year]
        let startOfDayComponents = calendar.components(unitFlags, fromDate: date)
        let startOfDay = calendar.dateFromComponents(startOfDayComponents)
        let intervalToStaryOfDay = startOfDay!.timeIntervalSince1970
        let daysDifference = floor(intervalToStaryOfDay) / 86400  // Number of seconds per day = 60 * 60 * 24 = 86400
        return Int(daysDifference)
    }
}
