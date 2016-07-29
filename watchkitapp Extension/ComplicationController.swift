//
//  ComplicationController.swift
//  watchkitapp Extension
//
//  Created by John Pollard on 29/07/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        let entry = self.createTimeLineEntry(complication.family, date:NSDate())
        handler(entry)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Not supporting timeline
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Not supporting timeline
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        
        // If next game time is before now, then ask for 10 mins, otherwise start of next game
        let settings = self.settingsData()
        let now = NSDate()

        let differenceInMinutes = NSCalendar.currentCalendar().components(.Minute, fromDate: settings.nextGameTime, toDate: now, options: []).minute
        
        if (differenceInMinutes >= 0) {
            // In game time, so ask again in 10 mins.
            let calendar = NSCalendar.currentCalendar()
            let tenMinutesTime = calendar.dateByAddingUnit(
                .Minute,
                value: 10,
                toDate: now,
                options: NSCalendarOptions.WrapComponents
            )
            
            handler(tenMinutesTime)
        } else {
            handler(settings.nextGameTime)
        }
    }
    
    // MARK: - Placeholder Templates
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        switch complication.family {
            case .ModularSmall:
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: "STO")
                template.line2TextProvider = CLKSimpleTextProvider(text: "2-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .ModularLarge:
                let template = CLKComplicationTemplateModularLargeStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: "Next game:")
                template.body1TextProvider = CLKSimpleTextProvider(text: "Stourbridge")
                template.body2TextProvider = CLKSimpleTextProvider(text: "Tue 26")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .UtilitarianSmall:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = CLKSimpleTextProvider(text: "2-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .UtilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                template.textProvider = CLKSimpleTextProvider(text: "Stourbridge 2-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
            case .CircularSmall:
                let template = CLKComplicationTemplateCircularSmallSimpleText()
                template.textProvider = CLKSimpleTextProvider(text: "2-0")
                template.tintColor = AppColors.WatchComplicationColor
                handler(template)
        }
    }
    
    // MARK: - Internal helper methods
    private func settingsData() -> WatchGameSettings {
        let appDelegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        return appDelegate.model
    }
    
    private func createTimeLineEntry(family: CLKComplicationFamily, date: NSDate) -> CLKComplicationTimelineEntry? {
        let settings = self.settingsData()
        
        var header = ""
        var opponent = ""
        var scoreOrDate = ""
        
        if (settings.gameScoreForCurrentGame) {
            // Game in progress
            header = "Current score:"
            opponent = settings.displayNextOpponent
            scoreOrDate = settings.currentScore
        } else {
            // Was the last game today?
            let isLastGameDay = NSCalendar.currentCalendar().isDate(date, inSameDayAsDate: settings.lastGameTime)
            
            if (isLastGameDay) {
                header = "Today's result:"
                opponent = settings.displayLastOpponent
                scoreOrDate = settings.lastScore
            } else {
                header = "Next game:"
                opponent = settings.displayNextOpponent
                scoreOrDate = settings.nextKickoffTimeShort
            }
        }
        
        let smallOpponent = opponent[opponent.startIndex..<opponent.startIndex.advancedBy(3)]
        let combinedInfo = String(format: "%@: %@", smallOpponent, scoreOrDate)
        
        var entry : CLKComplicationTimelineEntry?
        
        switch family {
            case .ModularSmall:
                let template = CLKComplicationTemplateModularSmallStackText()
                template.line1TextProvider = CLKSimpleTextProvider(text: String(smallOpponent))
                template.line2TextProvider = CLKSimpleTextProvider(text: String(scoreOrDate))
                template.tintColor = AppColors.WatchComplicationColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .ModularLarge:
                let template = CLKComplicationTemplateModularLargeStandardBody()
                template.headerTextProvider = CLKSimpleTextProvider(text: String(header))
                template.body1TextProvider = CLKSimpleTextProvider(text: String(opponent))
                template.body2TextProvider = CLKSimpleTextProvider(text: String(scoreOrDate))
                template.tintColor = AppColors.WatchComplicationColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .UtilitarianSmall:
                let template = CLKComplicationTemplateUtilitarianSmallFlat()
                template.textProvider = CLKSimpleTextProvider(text: String(scoreOrDate))
                template.tintColor = AppColors.WatchComplicationColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .UtilitarianLarge:
                let template = CLKComplicationTemplateUtilitarianLargeFlat()
                template.textProvider = CLKSimpleTextProvider(text: String(combinedInfo))
                template.tintColor = AppColors.WatchComplicationColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            case .CircularSmall:
                let template = CLKComplicationTemplateCircularSmallSimpleText()
                template.textProvider = CLKSimpleTextProvider(text: String(scoreOrDate))
                template.tintColor = AppColors.WatchComplicationColor
                entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        }
    
        return entry
    }
}
