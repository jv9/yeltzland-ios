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
    var webView: WKWebView!

    // Initializers
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    deinit {
        self.webView?.removeObserver(self, forKeyPath: "loading")
    }
    
    override func loadView() {
        super.loadView()
        
        self.webView = WKWebView()
        self.webView.navigationDelegate = self
        
        self.view = self.webView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        // Setup observation of web view events
        self.webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
    }
    
    // Nav bar actions
    func reloadButtonTouchUp() {
        let req = NSURLRequest(URL:self.webView.URL!)
        self.webView!.loadRequest(req)
        NSLog("Reloading page: %@", self.webView.URL!)
    }
    
    func backButtonTouchUp() {
        self.webView.goBack()
    }
    
    func forwardButtonTouchUp() {
        self.webView.goForward()
    }
    
    func loadHomePage() {
        let req = NSURLRequest(URL:self.homeUrl)
        self.webView!.loadRequest(req)
        NSLog("Loading page: %@", self.homeUrl)
    }
    
    // WebView observer
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "loading") {
            self.backButton.enabled = webView.canGoBack
            self.forwardButton.enabled = webView.canGoForward
        }
    }
    
    // MARK: - WKNavigationDelegate methods
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

