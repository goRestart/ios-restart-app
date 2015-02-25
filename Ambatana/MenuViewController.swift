//
//  MenuViewController.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaMenuOptionCellName = "AmbatanaMenuOptionCell"
private let kAmbatanaMenuOptionCellTitleTag = 1
private let kAmbatanaMenuOptionCellImageTag = 2


enum AmbatanaMenuOptions : Int {
    case MyProfile = 0, Conversations = 1, Sell = 2, Categories = 3, Help = 4
    /** Returns the title for the menu option */
    func titleForMenuOption() -> String {
        switch (self) {
        case .MyProfile:
            return translate("my_profile")
        case .Conversations:
            return translate("conversations")
        case .Sell:
            return translate("sell_something")
        case .Categories:
            return translate("categories")
        case .Help:
            return translate("help")
        }
    }
    
    static let numOptions = 5
    
    /** Returns the icon for the menu option */
    func iconForMenuOption() -> UIImage {
        switch (self) {
        case .MyProfile:
            return UIImage(named: "menu_profile")!
        case .Conversations:
            return UIImage(named: "menu_conversations")!
        case .Sell:
            return UIImage(named: "menu_sell")!
        case .Categories:
            return UIImage(named: "menu_categories")!
        case .Help:
            return UIImage(named: "menu_help")!
        }
    }
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // outlets & buttons
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // appearance
        tableView.separatorInset = UIEdgeInsetsZero
        if iOSVersionAtLeast("8.0") {
            tableView.layoutMargins = UIEdgeInsetsZero
            tableView.preservesSuperviewLayoutMargins = false
        }
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2.0
        userImageView.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // set user data
        userImageView.image = ConfigurationManager.sharedInstance.userProfileImage ?? UIImage(named: kAmbatanaDefaultUserImageName)
        userLocationLabel.text = ConfigurationManager.sharedInstance.userLocation
        userNameLabel.text = ConfigurationManager.sharedInstance.userName
        
        // register for user profile picture update notifications.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userPictureUpdated:", name: kAmbatanaUserPictureUpdatedNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // de-register from notifications center.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menuOption = AmbatanaMenuOptions(rawValue: indexPath.row)
        var segueName: String?

        switch (menuOption!) {
        case .MyProfile:
            // hacer esto? o un popToRootViewController.
            segueName = "EditProfile"
        case .Conversations:
            segueName = "Conversations"
        case .Sell:
            segueName = "SellProduct"
        case .Categories:
            segueName = "Categories"
        default:
            segueName = nil
            break;
        }

        // collapse menu.
        if segueName != nil {
            let navigationController = self.frostedViewController.contentViewController as AmbatanaNavigationController
            let visibleViewController = navigationController.visibleViewController
            
            visibleViewController.performSegueWithIdentifier(segueName, sender: nil)
        }
        self.frostedViewController.hideMenuViewController()
    }
    
    // MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AmbatanaMenuOptions.numOptions
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kAmbatanaMenuOptionCellName, forIndexPath: indexPath) as UITableViewCell
        // configure cell
        cell.layoutMargins = UIEdgeInsetsZero
        if let menuOption = AmbatanaMenuOptions(rawValue: indexPath.row) {
            let titleLabel = cell.viewWithTag(kAmbatanaMenuOptionCellTitleTag) as? UILabel
            let imageView = cell.viewWithTag(kAmbatanaMenuOptionCellImageTag) as? UIImageView
            
            // selectable?
            if menuOption == .Help { cell.selectionStyle = .None }
            else { cell.selectionStyle = .Default }
            
            titleLabel?.text = menuOption.titleForMenuOption()
            imageView?.image = menuOption.iconForMenuOption()
        }
        return cell
    }
    
    // MARK: - Navigation methods
    
    func mainNavigationController() -> AmbatanaNavigationController {
        return self.storyboard?.instantiateViewControllerWithIdentifier("navigationViewController") as AmbatanaNavigationController
    }
    
    // MARK: - Notifications
    
    func userPictureUpdated(notification: NSNotification) {
        if let updatedImage = notification.object as? UIImage {
            self.userImageView.image = updatedImage
        } else {
            self.userImageView.image = ConfigurationManager.sharedInstance.userProfileImage ?? UIImage(named: kAmbatanaDefaultUserImageName)
        }
    }
}










