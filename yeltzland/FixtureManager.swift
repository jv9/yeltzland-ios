//
//  FixtureManager.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

public class FixtureManager {
    private static let sharedInstance = FixtureManager()
    private var fixtureList:[String:[Fixture]] = [String:[Fixture]]()
    
    class var instance:FixtureManager {
        get {
            return sharedInstance
        }
    }
    
    public var Months: [String] {
        return Array(fixtureList.keys).sort()
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
            } catch {
                NSLog("Error loading fixtures from server ...")
                print(error)
            }
        }
    }
    
    private func parseMatchesJson(json:[String:AnyObject]) {
        let matches = json["Matches"] as! Array<AnyObject>
        
        self.fixtureList.removeAll()
        
        for currentMatch in matches {
            if let match = currentMatch as? [String:AnyObject] {
                let currentFixture = Fixture(fromJson: match)
                
                let monthFixtures = self.FixturesForMonth(currentFixture.monthKey)
                
                if monthFixtures != nil {
                    self.fixtureList[currentFixture.monthKey]?.append(currentFixture)
                } else {
                    self.fixtureList[currentFixture.monthKey] = [currentFixture]
                }
            }
        }
        
        // Sort the fixtures per month
        for currentMonth in Array(self.fixtureList.keys) {
            self.fixtureList[currentMonth] = self.fixtureList[currentMonth]?.sort({ $0.fixtureDate.compare($1.fixtureDate) == .OrderedAscending })
        }
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
    
}