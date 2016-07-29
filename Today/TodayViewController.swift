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
        if (GameSettings.instance.gameScoreForCurrentGame) {
            return 5
        }
        
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "FixtureTodayCell")
       
        var opponent: String = ""
        if (indexPath.row == 1) {
            opponent = GameSettings.instance.displayLastOpponent
        } else if (indexPath.row == 3) {
            opponent = GameSettings.instance.displayNextOpponent
        }
        
        cell.selectionStyle = .None
        cell.accessoryType = .None

        cell.textLabel?.font = UIFont(name: AppColors.AppFontName, size:AppColors.TodayTextSize)!
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.font = UIFont(name: AppColors.AppFontName, size: AppColors.TodayFootnoteSize)!
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
        if ((indexPath.row == 1) || (indexPath.row == 3)) {
            cell.textLabel?.textColor = AppColors.TodayText
            cell.detailTextLabel?.textColor = AppColors.TodayText
            
            if (opponent.characters.count > 0) {
                if (AppColors.isIos10AndAbove) {
                    
                    var resultColor = AppColors.TodayText
                    
                    if (indexPath.row == 1) {
                        let teamScore = GameSettings.instance.lastGameYeltzScore
                        let opponentScore  = GameSettings.instance.lastGameOpponentScore
                        
                        if (teamScore > opponentScore) {
                            resultColor = AppColors.FixtureWin
                        } else if (teamScore < opponentScore) {
                            resultColor = AppColors.FixtureLose
                        } else {
                            resultColor = AppColors.FixtureDraw
                        }
                    }
                    
                    cell.textLabel?.textColor = resultColor
                    cell.detailTextLabel?.textColor = resultColor
                }
                
                cell.textLabel?.text = String.init(format: "  %@", opponent)
                
                if (indexPath.row == 1) {
                    cell.detailTextLabel?.text = GameSettings.instance.lastScore
                } else {
                    if (GameSettings.instance.gameScoreForCurrentGame) {
                        cell.detailTextLabel?.text = GameSettings.instance.currentScore
                    } else {
                        cell.detailTextLabel?.text = GameSettings.instance.nextKickoffTime
                    }
                }
            } else {
                cell.textLabel?.text = "  None"
                cell.detailTextLabel?.text = ""
            }
        }
        else {
            if (indexPath.row == 0) {
                cell.textLabel?.text = "Last game:"
            } else if (indexPath.row == 2) {
                if (GameSettings.instance.gameScoreForCurrentGame) {
                    cell.textLabel?.text = "Current score:"
                } else {
                    cell.textLabel?.text = "Next game:"
                }
            } else {
                cell.textLabel?.text = "  (*best guess from Twitter)"
                cell.textLabel?.font = UIFont(name: AppColors.AppFontName, size:AppColors.TodayFootnoteSize)!
            }
            
            cell.detailTextLabel?.text = ""
            cell.detailTextLabel?.textColor = AppColors.TodaySectionText
            
            if (indexPath.row == 4) {
                cell.textLabel?.textColor = AppColors.TodayText
            } else {
                cell.textLabel?.textColor = AppColors.TodaySectionText
            }
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
