//
//  TodayViewController.swift
//  Today
//
//  Created by John Pollard on 27/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding {
    
    let CellRowHeight:CGFloat = 22.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update the fixture cache
        FixtureManager.instance.getLatestFixtures()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.view.backgroundColor = AppColors.TodayBackground
        self.tableView.separatorColor = AppColors.TodaySeparator
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        self.tableView.reloadData()
        self.preferredContentSize = CGSizeMake(0.0, self.CellRowHeight * 5)

        completionHandler(NCUpdateResult.NewData)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "FixtureTodayCell")
       
        var currentFixture: Fixture? = nil
        if (indexPath.row == 1) {
            currentFixture = FixtureManager.instance.getLastGame()
        } else if (indexPath.row == 3) {
            currentFixture = FixtureManager.instance.getNextGame()
        }
        
        cell.selectionStyle = .None
        cell.accessoryType = .None

        cell.textLabel?.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherTextSize)!
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.font = UIFont(name: AppColors.AppFontName, size: AppColors.OtherDetailTextSize)!
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        if ((indexPath.row == 1) || (indexPath.row == 3)) {
            cell.textLabel?.textColor = AppColors.TodayText
            cell.detailTextLabel?.textColor = AppColors.TodayText
            
            if (currentFixture != nil) {
                cell.textLabel?.text = String.init(format: "  %@", currentFixture!.displayOpponent)
                
                if (currentFixture!.teamScore == nil || currentFixture!.opponentScore == nil) {
                    cell.detailTextLabel?.text = currentFixture!.fullKickoffTime
                } else {
                    cell.detailTextLabel?.text = currentFixture!.score
                }
            } else {
                cell.textLabel?.text = "  None"
                cell.detailTextLabel?.text = ""
            }
        }
        else {
            if (indexPath.row == 0) {
                cell.textLabel?.text = "Last game:"
            } else {
                cell.textLabel?.text = "Next game:"
            }
            
            cell.detailTextLabel?.text = ""
            cell.textLabel?.textColor = AppColors.TodaySectionText
            cell.detailTextLabel?.textColor = AppColors.TodaySectionText
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = NSURL(string:"yeltzland://")
        print("Opening app")
        self.extensionContext?.openURL(url!, completionHandler: nil)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.CellRowHeight
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}
