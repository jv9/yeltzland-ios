//
//  MainTabBarController.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        // Colors
        self.tabBar.barTintColor = AppColors.TabBarColor
        self.tabBar.tintColor = AppColors.TabBarTextColor
    }
    
    override func viewWillAppear(animated: Bool) {
        // Official Site
        let officialViewController = WebPageViewController()
        officialViewController.homeUrl = NSURL(string:"http://www.ht-fc.com")
        officialViewController.pageTitle = "Official Site"
        let officialNavigationController = UINavigationController(rootViewController:officialViewController)
        
        let officialIcon = UITabBarItem(title: "Official Site", image: nil, selectedImage: nil)
        officialIcon.setFAIcon(FAType.FABlackTie)
        officialNavigationController.tabBarItem = officialIcon
        
        // Forum
        let forumViewController = WebPageViewController()
        forumViewController.homeUrl = NSURL(string:"http://www.yeltz.co.uk/0/")
        forumViewController.pageTitle = "Yeltz Forum"
        let forumNavigationController = UINavigationController(rootViewController:forumViewController)
        
        let forumIcon = UITabBarItem(title: "Yeltz Forum", image: nil, selectedImage: nil)
        forumIcon.setFAIcon(FAType.FAUsers)
        forumNavigationController.tabBarItem = forumIcon
        
        // Yeltz TV
        let tvViewController = WebPageViewController()
        tvViewController.homeUrl = NSURL(string:"https://www.youtube.com/user/HalesowenTownFC")
        tvViewController.pageTitle = "Yeltz TV"
        let tvNavigationController = UINavigationController(rootViewController:tvViewController)
        
        let tvIcon = UITabBarItem(title: "Yeltz TV", image: nil, selectedImage: nil)
        tvIcon.setFAIcon(FAType.FAYoutubePlay)
        tvNavigationController.tabBarItem = tvIcon
        
        // Twitter
        let twitterViewController = TwitterUserTimelineViewController()
        twitterViewController.userScreenName = "halesowentownfc"
        let twitterNavigationController = UINavigationController(rootViewController:twitterViewController)
        
        let twitterIcon = UITabBarItem(title: "Twitter", image: nil, selectedImage: nil)
        twitterIcon.setFAIcon(FAType.FATwitter)
        twitterNavigationController.tabBarItem = twitterIcon
        
        // Other Links
        let otherViewController = OtherLinksTableViewController()
        let otherNavigationController = UINavigationController(rootViewController:otherViewController)
        
        let otherIcon = UITabBarItem(tabBarSystemItem: .More, tag: 0)
        otherNavigationController.tabBarItem = otherIcon

        // Add controllers
        let controllers = [forumNavigationController, officialNavigationController, tvNavigationController, twitterNavigationController, otherNavigationController]
        self.viewControllers = controllers
    }
    
    // Delegate methods
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        //print("Should select viewController: \(viewController.title) ?")
        return true;
    }
}