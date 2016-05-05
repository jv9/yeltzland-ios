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
        self.navigationItem.title = "Other Sites"
        
        // Setup colors
        self.navigationController!.navigationBar.barTintColor = AppColors.NavBarColor;
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppColors.NavBarTextColor]
        
        self.view.backgroundColor = AppColors.OtherBackground
        self.tableView.separatorColor = AppColors.OtherSeparator
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        // Configure the cell...
        switch (indexPath.row) {
        case 0:
            cell.textLabel?.text = "NPL site"
            let cellImage = UIImage(icon: FAType.FASoccerBallO, size: CGSize(width: 100, height: 100), textColor: AppColors.Evostick, backgroundColor: UIColor.clearColor())
            cell.imageView?.image = cellImage
            break
        case 1:
            cell.textLabel?.text = "Fantasy Island"
            let cellImage = UIImage(icon: FAType.FAPlane, size: CGSize(width: 100, height: 100), textColor: AppColors.Fantasy, backgroundColor: UIColor.clearColor())
            cell.imageView?.image = cellImage
            break
        case 2:
            cell.textLabel?.text = "Stourbridge Town FC"
            let cellImage = UIImage(icon: FAType.FABan, size: CGSize(width: 100, height: 100), textColor: AppColors.Stour, backgroundColor: UIColor.clearColor())
            cell.imageView?.image = cellImage
            break
        case 3:
            cell.textLabel?.text = "Another Brave Location App!"
            let cellImage = UIImage(icon: FAType.FAMapMarker, size: CGSize(width: 100, height: 100), textColor: AppColors.BraveLocation, backgroundColor: UIColor.clearColor())
            cell.imageView?.image = cellImage

            let infoDictionary = NSBundle.mainBundle().infoDictionary!
            let version = infoDictionary["CFBundleShortVersionString"]
            let build = infoDictionary["CFBundleVersion"]
            
            cell.detailTextLabel?.text = "Current version: \(version!).\(build!)"
        default:
            break
        }
        
        cell.selectionStyle = .Default;
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var url: NSURL? = nil;
        
        switch (indexPath.row) {
        case 0:
            url = NSURL(string: "http://www.evostikleague.co.uk")
            break
        case 1:
            url = NSURL(string: "http://yeltz.co.uk/fantasyisland")
            break
        case 3:
            url = NSURL(string: "http://bravelocation.com/apps")
            break
        default:
            break
        }
        
        if (url != nil) {
            let svc = SFSafariViewController(URL: url!)
            self.presentViewController(svc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Really?", message: "Computer says no", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Sorry", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    // MARK: - SFSafariViewControllerDelegate methods
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
