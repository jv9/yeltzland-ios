//
//  GameScoreManager.swift
//  yeltzland
//
//  Created by John Pollard on 28/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

public class GameScoreManager {
    private var matchDate:NSDate? = nil
    private var yeltzScore:Int = 0
    private var opponentScore:Int = 0
    
    private static let sharedInstance = GameScoreManager()
    class var instance:GameScoreManager {
        get {
            return sharedInstance
        }
    }
    
    public var MatchDate: NSDate? {
        return self.matchDate
    }
    
    public var YeltzScore: Int {
        return self.yeltzScore
    }
    
    public var OpponentScore: Int {
        return self.opponentScore
    }
    
    init() {
        // Setup local data
        self.moveSingleBundleFileToAppDirectory("gamescore", fileType: "json")
        
        let data:NSData? = NSData.init(contentsOfFile: self.appDirectoryFilePath("gamescore", fileType: "json"))
        
        if (data == nil) {
            NSLog("Couldn't load game score from cache")
            return
        }
        
        do {
            NSLog("Loading game score from cache ...")
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String : AnyObject]
            
            if (json == nil) {
                NSLog("Couldn't parse game score from cache")
                return
            }
            
            self.parseGameScoreJson(json!)
            NSLog("Loaded game score from cache")
        } catch {
            NSLog("Error loading game score from cache ...")
            print(error)
        }
    }
    
    public func getLatestGameScore() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            NSLog("Loading fixtures from server ...")
            let dataUrl = NSURL(string: "http://bravelocation.com/automation/feeds/gamescore.json")!
            let serverData:NSData? = NSData.init(contentsOfURL: dataUrl)
            
            if (serverData == nil) {
                NSLog("Couldn't download game score from server")
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(serverData!, options: NSJSONReadingOptions()) as? [String : AnyObject]
                
                if (json == nil) {
                    NSLog("Couldn't parse game score from server")
                    return
                }
                
                self.parseGameScoreJson(json!)
                
                // Fetch went OK, so write to local file for next startup
                if (self.MatchDate != nil) {
                    NSLog("Saving server game score to cache")
                    
                    try serverData?.writeToFile(self.appDirectoryFilePath("gamescore", fileType: "json"), options: .DataWritingAtomic)
                }
                
                NSLog("Loaded game score from server")
                
                // Update game settings
                GameSettings.instance.refreshGameScore()
            } catch {
                NSLog("Error loading game score from server ...")
                print(error)
            }
        }
    }
    
    private func parseGameScoreJson(json:[String:AnyObject]) {
        // Clear settings
        self.matchDate = nil
        self.yeltzScore = 0
        self.opponentScore = 0
        
        if let currentMatch = json["match"] {
            let fixture = Fixture(fromJson: currentMatch as! [String : AnyObject])
            self.matchDate = fixture.fixtureDate
        }

        if let parsedYeltzScore = json["yeltzScore"] as? String {
            self.yeltzScore = Int(parsedYeltzScore)!
        }
        
        if let parsedOpponentScore = json["opponentScore"] as? String {
            self.opponentScore = Int(parsedOpponentScore)!
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