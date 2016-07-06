//
//  LocationAnnotation.swift
//  yeltzland
//
//  Created by John Pollard on 06/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import MapKit

class LocationAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, team: String) {
        self.coordinate = coordinate
        self.title = team
        
        // Find away games
        let awayGames = FixtureManager.instance.getAwayGames(team)
        
        if (awayGames.count == 0) {
            self.subtitle = ""
        } else {
            let lastGame = awayGames.last!
            if (lastGame.teamScore == nil || lastGame.opponentScore == nil) {
                self.subtitle = lastGame.fullKickoffTime
            } else {
                self.subtitle = lastGame.score
            }
        }
    }
}
