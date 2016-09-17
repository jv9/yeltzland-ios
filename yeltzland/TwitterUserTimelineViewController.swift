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

class TwitterUserTimelineViewController: TWTRTimelineViewController, TWTRTweetViewDelegate, SFSafariViewControllerDelegate {
    
    var userScreenName: String!
    var reloadButton: UIBarButtonItem!
    var timer: NSTimer!
    
    let TIMER_INTERVAL = 60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = TWTRAPIClient()
        self.dataSource = TWTRUserTimelineDataSource(screenName: self.userScreenName, APIClient: client)
        self.tweetViewDelegate = self
        
        // Setup navigation
        self.navigationItem.title = "@\(self.userScreenName)"
        
        self.reloadButton = UIBarButtonItem(
            title: "Reload",
            style: .Plain,
            target: self,
            action: #selector(TwitterUserTimelineViewController.reloadData)
        )
        self.reloadButton.FAIcon = FAType.FARotateRight
        self.reloadButton.tintColor = AppColors.NavBarTintColor
        
        self.navigationItem.rightBarButtonItems = [self.reloadButton]
        
        self.view.backgroundColor = AppColors.TwitterBackground
        self.tableView.separatorColor = AppColors.TwitterSeparator
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
   
    func tweetView(tweetView: TWTRTweetView, didTapURL url: NSURL) {
        let svc = SFSafariViewController(URL: url)
        self.presentViewController(svc, animated: true, completion: nil)
    }
    
    // MARK: - Nav bar actions
    func reloadData() {
        self.refresh()
        
        // Set a timer to refresh the data after interval period
        if (self.timer != nil) {
            self.timer.invalidate()
        }

        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.TIMER_INTERVAL, target: (self as AnyObject), selector: #selector(UITableView.reloadData), userInfo: nil, repeats: false)
    }
    
    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
