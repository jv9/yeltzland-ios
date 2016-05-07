//
//  AppDelegate.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Nav bar colors
        UINavigationBar.appearance().barTintColor = AppColors.NavBarColor;

        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: AppColors.NavBarTextColor,
            NSFontAttributeName: UIFont(name: AppColors.AppFontName, size: AppColors.NavBarTextSize)!
        ]
        
        // Tab bar font
        UITabBarItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: AppColors.AppFontName, size: AppColors.TabBarTextSize)!
        ], forState: .Normal)
        
        // Setup Fabric
        Fabric.with([Crashlytics.self, Twitter.self])
        
        // Initial web page
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let initialTabViewController = MainTabBarController()
        self.window?.rootViewController = initialTabViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

