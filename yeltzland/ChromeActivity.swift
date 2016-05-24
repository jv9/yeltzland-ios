//
//  ChromeActivity.swift
//  yeltzland
//
//  Created by John Pollard on 14/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class ChromeActivity: UIActivity {
    
    var currentUrl: NSURL?

    init(currentUrl: NSURL?) {
        self.currentUrl = currentUrl
        super.init()
    }
    
    override func activityType()-> String {
        return NSStringFromClass(self.classForCoder)
    }
    
    override func activityImage()-> UIImage
    {
        return UIImage(icon: FAType.FAChrome, size: CGSize(width: 66, height: 66), textColor: UIColor.blueColor(), backgroundColor: UIColor.clearColor())
    }
    
    override func activityTitle() -> String
    {
        return "Open in Chrome";
    }
    
    override class func activityCategory() -> UIActivityCategory{
        return UIActivityCategory.Action
    }
    
    func canOpenChrome() -> Bool {
        let chromeUrl = self.generateChromeUrl()
        if (chromeUrl == nil) {
            return false;
        }
        
        return UIApplication.sharedApplication().canOpenURL(chromeUrl)
    }
    
    func generateChromeUrl()-> NSURL!
    {
        let incomingScheme = self.currentUrl!.scheme
        var chromeScheme = ""
        
        if (incomingScheme == "http") {
            chromeScheme = "googlechrome"
        } else if (incomingScheme == "https") {
            chromeScheme = "googlechromes"
        }
        
        if (chromeScheme != "") {
            let chromeUrl = self.currentUrl!.absoluteString.stringByReplacingOccurrencesOfString(self.currentUrl!.scheme + "://", withString: chromeScheme + "://")
            print("Chrome URL is \(chromeUrl)")
            return NSURL(string:chromeUrl)!
        }
        
        return nil
    }
    
    override func performActivity() {
        print("Perform activity")
        
        let chromeUrl = self.generateChromeUrl()
        if (chromeUrl != nil) {
            if(UIApplication.sharedApplication().canOpenURL(chromeUrl)){
                UIApplication.sharedApplication().openURL(chromeUrl)
            }
        }
    }
}
