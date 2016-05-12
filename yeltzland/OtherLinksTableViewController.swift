//
//  OtherLinksTableViewController.swift
//  yeltzland
//
//  Created by John Pollard on 05/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import SafariServices
import Font_Awesome_Swift

class OtherLinksTableViewController: UITableViewController, SFSafariViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup navigation
        self.navigationItem.title = "Odds and Sods"
        
        self.view.backgroundColor = AppColors.OtherBackground
        self.tableView.separatorColor = AppColors.OtherSeparator
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0)
        {
            return 4
        } else if (section == 1) {
            return 2
        } else if (section == 2) {
            return 1
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        if (indexPath.section == 0) {
            switch (indexPath.row) {
            case 0:
                cell.textLabel?.text = "HTFC on Facebook"
                let cellImage = UIImage(icon: FAType.FAFacebookSquare, size: CGSize(width: 100, height: 100), textColor: AppColors.Facebook, backgroundColor: UIColor.clearColor())
                cell.imageView?.image = cellImage
                break
            case 1:
                cell.textLabel?.text = "NPL site"
                let cellImage = UIImage(icon: FAType.FASoccerBallO, size: CGSize(width: 100, height: 100), textColor: AppColors.Evostick, backgroundColor: UIColor.clearColor())
                cell.imageView?.image = cellImage
                break
            case 2:
                cell.textLabel?.text = "Fantasy Island"
                let cellImage = UIImage(icon: FAType.FAPlane, size: CGSize(width: 100, height: 100), textColor: AppColors.Fantasy, backgroundColor: UIColor.clearColor())
                cell.imageView?.image = cellImage
                break
            case 3:
                cell.textLabel?.text = "Stourbridge Town FC"
                let cellImage = UIImage(icon: FAType.FAThumbsODown, size: CGSize(width: 100, height: 100), textColor: AppColors.Stour, backgroundColor: UIColor.clearColor())
                cell.imageView?.image = cellImage
                break
            default:
                break
            }
        } else if (indexPath.section == 1) {
            switch (indexPath.row) {
            case 0:
                cell.textLabel?.text = "Yeltz Archives"
                let cellImage = UIImage(icon: FAType.FAArchive, size: CGSize(width: 100, height: 100), textColor: AppColors.Archive, backgroundColor: UIColor.clearColor())
                cell.imageView?.image = cellImage
                break
            case 1:
                cell.textLabel?.text = "Yeltzland News Archive"
                let cellImage = UIImage(icon: FAType.FANewspaperO, size: CGSize(width: 100, height: 100), textColor: AppColors.Archive, backgroundColor: UIColor.clearColor())
                cell.imageView?.image = cellImage
                break
            default:
                break
            }
        } else if (indexPath.section == 2) {
            cell.textLabel?.text = "Another Brave Location App!"
            let cellImage = UIImage(icon: FAType.FAMapMarker, size: CGSize(width: 100, height: 100), textColor: AppColors.BraveLocation, backgroundColor: UIColor.clearColor())
            cell.imageView?.image = cellImage
            
            let infoDictionary = NSBundle.mainBundle().infoDictionary!
            let version = infoDictionary["CFBundleShortVersionString"]
            let build = infoDictionary["CFBundleVersion"]
            
            cell.detailTextLabel?.text = "Current version: \(version!).\(build!)"
        }
        
        cell.selectionStyle = .Default;
        cell.accessoryType = .DisclosureIndicator

        // Set fonts
        cell.textLabel?.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherTextSize)!
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.font = UIFont(name: AppColors.AppFontName, size: AppColors.OtherDetailTextSize)!
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var url: NSURL? = nil;
        if (indexPath.section == 0) {
            switch (indexPath.row) {
            case 0:
                url = NSURL(string: "https://www.facebook.com/halesowentownfc/")
                break
            case 1:
                url = NSURL(string: "http://www.evostikleague.co.uk")
                break
            case 2:
                url = NSURL(string: "http://yeltz.co.uk/fantasyisland")
                break
            default:
                break
            }
        } else if (indexPath.section == 1) {
            switch (indexPath.row) {
            case 0:
                url = NSURL(string: "http://www.yeltzarchives.com")
                break
            case 1:
                url = NSURL(string: "http://www.yeltzland.net/news.html")
                break
            default:
                break
            }
        } else if (indexPath.section == 2) {
            url = NSURL(string: "http://bravelocation.com/apps")
        }
        
        if (url != nil) {
            let svc = SFSafariViewController(URL: url!)
            self.presentViewController(svc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Really?", message: "Computer says no", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String
    {
        switch(section)
        {
        case 0:
            return "Other websites"
        case 1:
            return "Know Your History"
        case 2:
            return "About the app"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = AppColors.OtherSectionBackground
        header.textLabel!.textColor = AppColors.OtherSectionText
        header.textLabel!.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherSectionTextSize)!
    }
    
    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
