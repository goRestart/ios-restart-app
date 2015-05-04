//
//  MenuViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 04/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Parse
import MessageUI
import UIKit

private let kLetGoMenuOptionCellName = "LetGoMenuOptionCell"
private let kLetGoMenuOptionCellTitleTag = 1
private let kLetGoMenuOptionCellImageTag = 2
private let kLetGoMenuOptionCellBadgeTag = 3


enum LetGoMenuOptions : Int {
    case Sell = 0, Conversations = 1, Categories = 2, Contact = 3, MyProfile = 4
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
        case .Contact:
            return translate("contact")
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
        case .Contact:
            return UIImage(named: "menu_contact_black")!
        }
    }
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    // outlets & buttons
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // appearance
        userNameLabel.text = ""
        userLocationLabel.text = ""
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.tableFooterView = UIView(frame: CGRectZero)
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // set user data
        userImageView.image = ConfigurationManager.sharedInstance.userProfileImage ?? UIImage(named: kLetGoDefaultUserImageName)
        userLocationLabel.text = ConfigurationManager.sharedInstance.userLocation
        userNameLabel.text = ConfigurationManager.sharedInstance.userName
        
        // register for user profile picture update notifications.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userPictureUpdated:", name: kLetGoUserPictureUpdatedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "badgeChanged:", name: kLetGoUserBadgeChangedNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // de-register from notifications center.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - UITableViewDelegate methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menuOption = LetGoMenuOptions(rawValue: indexPath.row)
        var segueName: String?

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController?
        var shouldHideHamburguerMenu = true
        
        switch (menuOption!) {
        case .MyProfile:
            let epvc = storyboard.instantiateViewControllerWithIdentifier("editProfileViewController") as! EditProfileViewController
            epvc.userObject = PFUser.currentUser()
            vc = epvc
        case .Conversations:
            let clvc = storyboard.instantiateViewControllerWithIdentifier("conversationsViewController") as! ChatListViewController
            vc = clvc
        case .Sell:
            let mpvc = storyboard.instantiateViewControllerWithIdentifier("myProfileViewController") as! SellProductViewController
            vc = mpvc
        case .Categories:
            let cvc = storyboard.instantiateViewControllerWithIdentifier("categoriesViewController") as! CategoriesViewController
            vc = cvc
        case .Contact:
            vc = nil
            shouldHideHamburguerMenu = false
            contactUs()
        }

        if let viewController = vc {
            // disable sliding menu for pushed controllers
            self.findHamburguerViewController()?.gestureEnabled = false
            
            // push vc
            let navigationController = self.mainNavigationController()
            navigationController.visibleViewController.navigationController?.pushViewController(viewController, animated: true)
            
            
//            navigationController.visibleViewController.pushViewController(viewController, animated: true)
            
            
            self.findHamburguerViewController()?.contentViewController = navigationController
        }
        if shouldHideHamburguerMenu {
            self.findHamburguerViewController()?.hideMenuViewControllerWithCompletion(nil)
        }
    }
    
    // MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LetGoMenuOptions.numOptions
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kLetGoMenuOptionCellName, forIndexPath: indexPath) as! UITableViewCell
        // configure cell
        if iOSVersionAtLeast("8.0") { cell.layoutMargins = UIEdgeInsetsZero }
        else { cell.separatorInset = UIEdgeInsetsZero }
        
        if let menuOption = LetGoMenuOptions(rawValue: indexPath.row) {
            let titleLabel = cell.viewWithTag(kLetGoMenuOptionCellTitleTag) as? UILabel
            let imageView = cell.viewWithTag(kLetGoMenuOptionCellImageTag) as? UIImageView
            let badgeView = cell.viewWithTag(kLetGoMenuOptionCellBadgeTag) as? UILabel
            
            // selectable?
            cell.selectionStyle = .Default
            
            titleLabel?.text = menuOption.titleForMenuOption()
            imageView?.image = menuOption.iconForMenuOption()
            // badge?
            if menuOption == .Conversations {
                let badgeNumber = PFInstallation.currentInstallation().badge
                if badgeNumber > 0 {
                    badgeView?.hidden = false
                    badgeView?.text = "\(PFInstallation.currentInstallation().badge)"
                    badgeView?.layer.cornerRadius = badgeView!.frame.size.height / 2.0
                    badgeView?.clipsToBounds = true
                } else { badgeView?.hidden = true }
            } else { badgeView?.hidden = true }
        }
        return cell
    }
    
    // MARK: - Button actions
    
    @IBAction func goToUserProfile(sender: AnyObject) {
        // disable sliding menu for pushed controllers
        self.findHamburguerViewController()?.gestureEnabled = false
        
        // push vc
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let epvc = storyboard.instantiateViewControllerWithIdentifier("editProfileViewController") as! EditProfileViewController
        epvc.userObject = PFUser.currentUser()

        let navigationController = self.mainNavigationController()
        navigationController.visibleViewController.navigationController?.pushViewController(epvc, animated: true)
        
        self.findHamburguerViewController()?.contentViewController = navigationController
        self.findHamburguerViewController()?.hideMenuViewControllerWithCompletion(nil)
    }
    
    // MARK: - Mail Composer Delegate methods
    
    func contactUs() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerController: MFMailComposeViewController! = MFMailComposeViewController()
            mailComposerController.mailComposeDelegate = self
            mailComposerController.setToRecipients(["barbara@letgo.com"])
            mailComposerController.setSubject(translate("feedback_letgo_user"))
            mailComposerController.setMessageBody(translate("type_your_message_here"), isHTML: true)
            self.presentViewController(mailComposerController, animated: true, completion: nil)
        } else {
            self.showAutoFadingOutMessageAlert(translate("errorsendingmail_contact"), completionBlock: { (_) -> Void in
                self.findHamburguerViewController()?.hideMenuViewControllerWithCompletion(nil)
            })

        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        var message: String? = nil
        if result.value == MFMailComposeResultFailed.value { // we just give feedback if something nasty happened.
            message = translate("errorsendingmail")
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.findHamburguerViewController()?.hideMenuViewControllerWithCompletion(nil)
            if message != nil { self.showAutoFadingOutMessageAlert(message!) }
        })
        
    }
    
    // MARK: - Navigation methods
    
    func mainNavigationController() -> DLHamburguerNavigationController {
        let productsVC = ProductsViewController()
        return DLHamburguerNavigationController(rootViewController: productsVC)
    }
    
    // MARK: - Notifications
    
    func userPictureUpdated(notification: NSNotification) {
        if let updatedImage = notification.object as? UIImage {
            self.userImageView.image = updatedImage
        } else {
            self.userImageView.image = ConfigurationManager.sharedInstance.userProfileImage ?? UIImage(named: kLetGoDefaultUserImageName)
        }
    }
    
    func badgeChanged (notification: NSNotification) {
        self.tableView.reloadData()
        //println("Badge changed!")
    }
}










