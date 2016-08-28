//
//  ViewController.swift
//  yeltzland
//
//  Created by John Pollard on 04/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import Whisper

class WebPageViewController: UIViewController, UIWebViewDelegate {
    
    var pageUrl: NSURL!
    // Properties
    
    var homeUrl: NSURL! {
        set {
            self.pageUrl = newValue;
            self.loadHomePage()
        }
        get {
            return self.pageUrl
        }
    }
    var pageTitle: String!
    
    var homeButton: UIBarButtonItem!
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    
    // Reference to WebView control we will instantiate
    let webView = UIWebView()
    let progressBar = UIProgressView(progressViewStyle: .Bar)
    var spinner: UIActivityIndicatorView!

    // Initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupNotificationWatchers()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.loadHomePage()
        self.setupNotificationWatchers()
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("Removed notification handler for fixture updates in today view")
    }
    
    private func setupNotificationWatchers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WebPageViewController.enterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)

    }
    
    @objc private func enterForeground(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.reloadButtonTouchUp()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Calculate position on screen of elements
        let progressBarHeight = CGFloat(2.0)
        let topPosition = (self.navigationController?.navigationBar.frame.size.height)! + CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        
        let webViewHeight = CGRectGetHeight(view.frame) -
            (topPosition + progressBarHeight + CGRectGetHeight((self.tabBarController?.tabBar.frame)!));

        // Add elements to view
        self.webView.frame = CGRect(x: 0, y: topPosition + progressBarHeight, width: view.frame.width, height: webViewHeight)
        self.webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.webView.delegate = self
        
        self.progressBar.frame = CGRect(x: 0, y: topPosition, width: view.frame.width, height: progressBarHeight)
        self.progressBar.alpha = 0
        self.progressBar.tintColor = AppColors.ProgressBar
        self.progressBar.autoresizingMask = .FlexibleWidth
        
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.webView)
        self.view.backgroundColor = AppColors.WebBackground
        
        // Setup navigation
        self.navigationItem.title = self.pageTitle
        
        self.reloadButton = UIBarButtonItem(
            barButtonSystemItem:.Refresh,
            target: self,
            action: #selector(WebPageViewController.reloadButtonTouchUp)
        )
        
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
        
        self.shareButton = UIBarButtonItem(
            barButtonSystemItem:.Action,
            target: self,
            action: #selector(WebPageViewController.shareButtonTouchUp)
        )

        self.backButton.enabled = false
        self.forwardButton.enabled = false
        
        self.navigationItem.leftBarButtonItems = [self.homeButton, self.backButton, self.forwardButton]
        self.navigationItem.rightBarButtonItems = [self.shareButton, self.reloadButton]
        
        // Setup colors
        self.backButton.tintColor = AppColors.NavBarTintColor
        self.forwardButton.tintColor = AppColors.NavBarTintColor
        self.reloadButton.tintColor = AppColors.NavBarTintColor
        self.homeButton.tintColor = AppColors.NavBarTintColor
        self.shareButton.tintColor = AppColors.NavBarTintColor
        
        // TODO: Add swipe gestures?
        //self.webView.allowsBackForwardNavigationGestures = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("Reloading in view will appear...")
        self.reloadButtonTouchUp()
    }
    
    // MARK: - Nav bar actions
    func reloadButtonTouchUp() {
        progressBar.setProgress(0, animated: false)
        self.webView.reload()
    }
    
    func backButtonTouchUp() {
        self.webView.goBack()
    }
    
    func forwardButtonTouchUp() {
        self.webView.goForward()
    }
    
    func loadHomePage() {
        self.webView.stopLoading()
        progressBar.setProgress(0, animated: false)
        
        if let requestUrl = self.homeUrl {
            let req = NSURLRequest(URL: requestUrl)
            self.webView.loadRequest(req)
            NSLog("Loading page: %@", self.homeUrl)
        }
    }
    
    func shareButtonTouchUp() {
        if let requestUrl = self.webView.request!.URL {
            let objectsToShare = [requestUrl]

            // Add custom activities as appropriate
            let safariActivity = SafariActivity(currentUrl: requestUrl)
            let chromeActivity = ChromeActivity(currentUrl: requestUrl)
            
            var customActivities:[UIActivity] = [safariActivity]
            if (chromeActivity.canOpenChrome()) {
                customActivities.append(chromeActivity);
            }
            
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: customActivities)
            
            if (activityViewController.popoverPresentationController != nil) {
                activityViewController.popoverPresentationController!.barButtonItem = self.shareButton;
            }
            
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    func showSpinner() {
        if (self.spinner != nil) {
            self.hideSpinner()
        }
        
        let overlayPosition = CGRectMake(0, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)
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
    
    // MARK: - UIWebViewDelegate methods
    func webView(webView: UIWebView,
                   shouldStartLoadWithRequest request: NSURLRequest,
                                              navigationType: UIWebViewNavigationType) -> Bool {
        let loadingUrl = request.URL!.absoluteString
        var pageUrl = ""
        if (webView.request != nil && webView.request!.URL != nil) {
            pageUrl = webView.request!.URL!.absoluteString
        }
        
        // If main page, show the spinner and start the progress
        if (loadingUrl == pageUrl) {
            self.showSpinner()
            self.progressBar.setProgress(0.5, animated: true)
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 1 }, completion: nil)
        } else {
            // Otherwise just increment the progress a little
            if (self.progressBar.progress < 0.99) {
                self.progressBar.setProgress(self.progressBar.progress + 0.01, animated: true)
            }
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        // Mark the progress as done
        self.hideSpinner()
        hide(whisperFrom: self.navigationController!, after: 5.0)
        
        progressBar.setProgress(1, animated: true)
        UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        self.backButton.enabled = webView.canGoBack
        self.forwardButton.enabled = webView.canGoForward
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        // Mark the progress as done
        self.hideSpinner()
        progressBar.setProgress(1, animated: true)
        UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        // Show brief error message
        if (error != nil) {
            // Check if main page failed ...
            if let failingUrl = error!.userInfo["NSErrorFailingURLStringKey"] {
                let errorUrl = failingUrl as! String
                let pageUrl = webView.request!.URL!.absoluteString
                if (errorUrl == pageUrl) {
                    // If it was the main page, show the error as a Whisper
                    let message = Message(title: "Couldn't connect to the website right now", backgroundColor: AppColors.WebErrorBackground)
                    show(whisper: message, to: self.navigationController!)
                    hide(whisperFrom: self.navigationController!, after: 5.0)
                    
                    self.backButton.enabled = webView.canGoBack
                    self.forwardButton.enabled = webView.canGoForward
                    
                    print("Couldn't load page: \(errorUrl)")
               } else {
                    print("Couldn't load resource: \(errorUrl)")
                }
            }
        }
    }
}

