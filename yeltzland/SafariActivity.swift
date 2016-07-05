//
//  SafariActivity.swift
//  yeltzland
//
//  Created by John Pollard on 14/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class SafariActivity: UIActivity {
    
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
        return UIImage(icon: FAType.FASafari, size: CGSize(width: 66, height: 66), textColor: UIColor.blueColor(), backgroundColor: UIColor.clearColor())
    }
    
    override func activityTitle() -> String
    {
        return "Open in Safari";
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        // nothing to prepare
    }
    
    override class func activityCategory() -> UIActivityCategory{
        return UIActivityCategory.Action
    }
    
    func canOpenChrome() -> Bool {
        if (self.currentUrl == nil) {
            return false;
        }
        
        return UIApplication.sharedApplication().canOpenURL(self.currentUrl!)
    }
    
    override func performActivity() {
        print("Perform activity")
        
        if (self.currentUrl != nil) {
            if(UIApplication.sharedApplication().canOpenURL(self.currentUrl!)){
                UIApplication.sharedApplication().openURL(self.currentUrl!)
            }
        }
    }
}
