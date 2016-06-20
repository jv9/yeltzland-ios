//
//  Fixture.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation

public class Fixture {
    var fixtureDate: NSDate
    var opponent: String
    var home: Bool
    var teamScore: Int?
    var opponentScore: Int?
    
    init(fromJson: [String:AnyObject]) {
        // Parse properties from JSON match properties
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.fixtureDate = formatter.dateFromString(fromJson["MatchDateTime"] as! String)!
        
        self.opponent = fromJson["Opponent"] as! String
        self.home = ((fromJson["Home"] as! String) == "1")
        
        // Parse scores or "null"
        if let parsedTeamScore = fromJson["TeamScore"] as? String {
            self.teamScore = Int(parsedTeamScore)
        }
        
        if let parsedOpponentScore = fromJson["OpponentScore"] as? String {
            self.opponentScore = Int(parsedOpponentScore)
        }
    }
    
    init(date: NSDate, opponent:String, home:Bool, teamScore: Int?, opponentScore: Int?) {
        self.fixtureDate = date
        self.opponent = opponent
        self.home = home
        self.teamScore = teamScore
        self.opponentScore = opponentScore
    }
    
    var kickoffTime: String {
        get {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE dd @HHmm"
            
            return formatter.stringFromDate(self.fixtureDate)
        }
    }
    
    var fixtureMonth: String {
        get {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            
            return formatter.stringFromDate(self.fixtureDate)
        }
    }
    
    var monthKey: String {
        get {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMM"
            
            return formatter.stringFromDate(self.fixtureDate)
        }
    }
    
    var displayOpponent: String {
        get {
            return self.home ? self.opponent.uppercaseString : self.opponent
        }
    }
    
    var score: String {
        get {
            if ((self.teamScore == nil) || (self.opponentScore == nil)) {
                return ""
            }
            
            var result = ""
            if (self.teamScore > self.opponentScore) {
                result = "W"
            } else if (self.teamScore < self.opponentScore) {
                result = "L"
            } else {
                result = "D"
            }
            
            return String.init(format: "%@ %d-%d", result, self.teamScore!, self.opponentScore!)
        }
    }
}