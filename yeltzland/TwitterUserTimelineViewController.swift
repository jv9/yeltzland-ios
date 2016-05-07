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
    var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = TWTRAPIClient()
        self.dataSource = TWTRUserTimelineDataSource(screenName: self.userScreenName, APIClient: client)
        self.tweetViewDelegate = self
        
        // Setup navigation
        self.navigationItem.title = "@\(self.userScreenName)"
                
        self.view.backgroundColor = AppColors.TwitterBackground
        self.tableView.separatorColor = AppColors.TwitterSeparator
        self.showSpinner()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == tableView.indexPathsForVisibleRows!.last!.row) {
            self.hideSpinner()
        }
    }
    
    func showSpinner() {
        if (self.spinner != nil) {
            self.hideSpinner()
        }
        
        let topPosition = (self.navigationController?.navigationBar.frame.size.height)! + CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        let tableViewHeight = CGRectGetHeight(view.frame) -
            (topPosition + CGRectGetHeight((self.tabBarController?.tabBar.frame)!));
        let overlayPosition = CGRectMake(0, self.view.bounds.origin.y, self.view.bounds.size.width, tableViewHeight)
        
        self.spinner = UIActivityIndicatorView(frame:overlayPosition)
        self.spinner.color = AppColors.SpinnerColor
        self.view.addSubview(self.spinner)
        self.spinner.startAnimating()
    }
    
    func hideSpinner() {
        if (self.spinner != nil) {
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
            self.spinner = nil;
        }
    }
    
    func tweetView(tweetView: TWTRTweetView, didTapURL url: NSURL) {
        let svc = SFSafariViewController(URL: url)
        self.presentViewController(svc, animated: true, completion: nil)
    }
    
    
    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
