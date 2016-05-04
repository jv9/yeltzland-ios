//
//  TwitterUserTimelineViewController.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit
import SafariServices
import Font_Awesome_Swift

class TwitterUserTimelineViewController: TWTRTimelineViewController {
    
    var userScreenName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = TWTRAPIClient()
        self.dataSource = TWTRUserTimelineDataSource(screenName: self.userScreenName, APIClient: client)
        
        // Setup navigation
        self.navigationItem.title = "Twitter"
        
        // Setup colors
        self.navigationController!.navigationBar.barTintColor = AppColors.NavBarColor;
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppColors.NavBarTextColor]
        
        self.view.backgroundColor = AppColors.TwitterBackground
        self.tableView.separatorColor = AppColors.TwitterSeparator
    }
}
