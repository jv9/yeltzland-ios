//
//  ViewController.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import WebKit
import Font_Awesome_Swift

class WebPageViewController: UIViewController, WKNavigationDelegate {
    
    // Properties
    var homeUrl: NSURL!
    var pageTitle: String!
    
    var homeButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    
    // reference to WebView control we will instantiate
    let webView = WKWebView()
    let progressBar = UIProgressView(progressViewStyle: .Bar)

    // Initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Calculate position on screen of elements
        let progressBarHeight = CGFloat(2.0)
        let topPosition = (self.navigationController?.navigationBar.frame.size.height)! + CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        
        let webViewHeight = CGRectGetHeight(view.frame) -
            (topPosition + progressBarHeight + CGRectGetHeight((self.tabBarController?.tabBar.frame)!));
        
        NSLog("topPosition: \(topPosition): webViewHeight: \(webViewHeight)")

        // Add elements to view
        self.webView.frame = CGRect(x: 0, y: topPosition + progressBarHeight, width: view.frame.width, height: webViewHeight)
        self.webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.webView.navigationDelegate = self
        
        self.progressBar.frame = CGRect(x: 0, y: topPosition, width: view.frame.width, height: progressBarHeight)
        self.progressBar.alpha = 0
        self.progressBar.tintColor = AppColors.ProgressBar
        self.progressBar.autoresizingMask = .FlexibleWidth
        
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.webView)
        self.view.backgroundColor = AppColors.WebBackground

        self.loadHomePage()
        
        // Setup navigation
        self.navigationItem.title = self.pageTitle
        
        self.reloadButton = UIBarButtonItem(
            title: "Reload",
            style: .Plain,
            target: self,
            action: #selector(WebPageViewController.reloadButtonTouchUp)
        )
        self.reloadButton.FAIcon = FAType.FARefresh
        
        self.homeButton = UIBarButtonItem(
            title: "Home",
            style: .Plain,
            target: self,
            action: #selector(WebPageViewController.loadHomePage)
        )
        self.homeButton.FAIcon = FAType.FAHome
        
        self.backButton = UIBarButtonItem(
            title: "Back",
            style: .Plain,
            target: self,
            action: #selector(WebPageViewController.backButtonTouchUp)
        )
        self.backButton.FAIcon = FAType.FAAngleLeft
        
        self.forwardButton = UIBarButtonItem(
            title: "Forward",
            style: .Plain,
            target: self,
            action: #selector(WebPageViewController.forwardButtonTouchUp)
        )
        self.forwardButton.FAIcon = FAType.FAAngleRight
        
        self.backButton.enabled = false
        self.forwardButton.enabled = false
        
        self.navigationItem.leftBarButtonItems = [self.backButton, self.forwardButton]
        self.navigationItem.rightBarButtonItems = [self.reloadButton, self.homeButton]
        
        // Setup colors
        self.navigationController!.navigationBar.barTintColor = AppColors.NavBarColor;
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppColors.NavBarTextColor]
        
        self.backButton.tintColor = AppColors.NavBarTintColor
        self.forwardButton.tintColor = AppColors.NavBarTintColor
        self.reloadButton.tintColor = AppColors.NavBarTintColor
        self.homeButton.tintColor = AppColors.NavBarTintColor
        
        // Swipe gestures automatically supported
        self.webView.allowsBackForwardNavigationGestures = true
    }
    
    // Nav bar actions
    func reloadButtonTouchUp() {
        progressBar.setProgress(0, animated: false)
        
        let req = NSURLRequest(URL:self.webView.URL!)
        self.webView.loadRequest(req)
        NSLog("Reloading page: %@", self.webView.URL!)
    }
    
    func backButtonTouchUp() {
        self.webView.goBack()
    }
    
    func forwardButtonTouchUp() {
        self.webView.goForward()
    }
    
    func loadHomePage() {
        progressBar.setProgress(0, animated: false)
        let req = NSURLRequest(URL:self.homeUrl)
        self.webView.loadRequest(req)
        NSLog("Loading page: %@", self.homeUrl)
    }
    
    
    // MARK: - WKNavigationDelegate methods
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        self.progressBar.setProgress(0, animated: false)
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 1 }, completion: nil)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation){
        progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation) {
        progressBar.setProgress(1, animated: true)
        UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        self.backButton.enabled = webView.canGoBack
        self.forwardButton.enabled = webView.canGoForward
    }
    
    func webView(webView: WKWebView, navigation: WKNavigation, withError error: NSError) {
        progressBar.setProgress(1, animated: true)
        UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        let alert:UIAlertController = UIAlertController(title: "Error", message: "Could not load webpage", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

