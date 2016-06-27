//
//  FixturesTableViewController.swift
//  yeltzland
//
//  Created by John Pollard on 20/06/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

class FixturesTableViewController: UITableViewController {
    
    var reloadButton: UIBarButtonItem!
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.setupNotificationWatcher()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNotificationWatcher()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("Removed notification handler for fixture updates")
    }
    
    private func setupNotificationWatcher() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FixturesTableViewController.fixturesUpdated), name: FixtureManager.FixturesNotification, object: nil)
        print("Setup notification handler for fixture updates")
    }
    
    @objc private func fixturesUpdated(notification: NSNotification) {
        print("Fixture update message received")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    func reloadButtonTouchUp() {
        FixtureManager.instance.getLatestFixtures()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup navigation
        self.navigationItem.title = "Fixtures"
        
        self.view.backgroundColor = AppColors.OtherBackground
        self.tableView.separatorColor = AppColors.OtherSeparator
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "FixtureCell")
        
        // Setup refresh button
        self.reloadButton = UIBarButtonItem(
            title: "Reload",
            style: .Plain,
            target: self,
            action: #selector(FixturesTableViewController.reloadButtonTouchUp)
        )
        self.reloadButton.FAIcon = FAType.FARotateRight
        self.reloadButton.tintColor = AppColors.NavBarTintColor
        self.navigationController?.navigationBar.tintColor = AppColors.NavBarTintColor
        self.navigationItem.rightBarButtonItems = [self.reloadButton]
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return FixtureManager.instance.Months.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let months = FixtureManager.instance.Months;
        let fixturesForMonth = FixtureManager.instance.FixturesForMonth(months[section])
        
        return fixturesForMonth!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "FixtureCell")

        // Find the fixture
        let months = FixtureManager.instance.Months;
        let fixturesForMonth = FixtureManager.instance.FixturesForMonth(months[indexPath.section])
        
        let currentFixture = fixturesForMonth![indexPath.row]

        cell.selectionStyle = .None
        cell.accessoryType = .None
        
        var resultColor = AppColors.FixtureNone
        
        if (currentFixture.teamScore == nil || currentFixture.opponentScore == nil) {
            resultColor = AppColors.FixtureNone
        } else if (currentFixture.teamScore > currentFixture.opponentScore) {
            resultColor = AppColors.FixtureWin
        } else if (currentFixture.teamScore < currentFixture.opponentScore) {
            resultColor = AppColors.FixtureLose
        } else {
            resultColor = AppColors.FixtureDraw
        }
        
        cell.textLabel?.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherTextSize)!
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        cell.detailTextLabel?.font = UIFont(name: AppColors.AppFontName, size: AppColors.OtherDetailTextSize)!
        cell.detailTextLabel?.textColor = resultColor
        
        cell.textLabel?.text = currentFixture.displayOpponent
        
        if (currentFixture.teamScore == nil || currentFixture.opponentScore == nil) {
            cell.detailTextLabel?.text = currentFixture.kickoffTime
        } else {
            cell.detailTextLabel?.text = currentFixture.score
        }

        
        return cell
    }
    
    override func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String
    {
        let months = FixtureManager.instance.Months;
        let fixturesForMonth = FixtureManager.instance.FixturesForMonth(months[section])!
        return fixturesForMonth[0].fixtureMonth
        
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = AppColors.OtherSectionBackground
        header.textLabel!.textColor = AppColors.OtherSectionText
        header.textLabel!.font = UIFont(name: AppColors.AppFontName, size:AppColors.OtherSectionTextSize)!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 33.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}
