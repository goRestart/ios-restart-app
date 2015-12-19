//
//  SettingsViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 13/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Parse
import Result
import SDWebImage
import UIKit
import FBSDKShareKit

private let kLetGoSettingsTableCellImageTag = 1
private let kLetGoSettingsTableCellTitleTag = 2

private let kLetGoUserImageSquareSize: CGFloat = 1024

enum LetGoUserSettings: Int {
    case InviteFbFriends = 0, ChangePhoto = 1, ChangeUsername = 2, ChangeLocation = 3, ChangePassword = 4, ContactUs = 5, Help = 6, LogOut = 7
    
    static func numberOfOptions() -> Int { return 8 }
    
    func titleForSetting() -> String {
        switch (self) {
        case .InviteFbFriends:
            return LGLocalizedString.settingsInviteFacebookFriendsButton
        case .ChangePhoto:
            return LGLocalizedString.settingsChangeProfilePictureButton
        case .ChangeUsername:
            return LGLocalizedString.settingsChangeUsernameButton
        case .ChangeLocation:
            return LGLocalizedString.settingsChangeLocationButton
        case .ChangePassword:
            return LGLocalizedString.settingsChangePasswordButton
        case .ContactUs:
            return LGLocalizedString.settingsContactUsButton
        case .Help:
            return LGLocalizedString.settingsHelpButton
        case .LogOut:
            return LGLocalizedString.settingsLogoutButton
        }
    }
    
    func imageForSetting() -> UIImage? {
        switch (self) {
        case .InviteFbFriends:
            return UIImage(named: "ic_fb_settings")
        case .ChangeUsername:
            return UIImage(named: "ic_change_username")
        case .ChangeLocation:
            return UIImage(named: "ic_location_edit")
        case .ChangePassword:
            return UIImage(named: "edit_profile_password")
        case .ContactUs:
            return UIImage(named: "ic_contact")
        case .Help:
            return UIImage(named: "ic_help")
        case .LogOut:
            return UIImage(named: "edit_profile_logout")
        default:
            return nil
        }
    }
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBSDKAppInviteDialogDelegate {

    // constants
    private static let cellIdentifier = "SettingsCell"
    
    // outlets & buttons
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingProfileImageView: UIView!
    @IBOutlet weak var settingProfileImageLabel: UILabel!
    @IBOutlet weak var settingProfileImageProgressView: UIProgressView!
    
    init() {
        super.init(nibName: "SettingsViewController", bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // internationalization
        settingProfileImageLabel.text = LGLocalizedString.settingsChangeProfilePictureLoading
        
        // appearance
        settingProfileImageView.hidden = true
        setLetGoNavigationBarStyle(LGLocalizedString.settingsTitle)
        
        // tableview
        let cellNib = UINib(nibName: "SettingsCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: SettingsViewController.cellIdentifier)
        tableView.rowHeight = 60
        
        let trackerEvent = TrackerEvent.profileEditStart()
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: LetGoUserSettings.ChangeUsername.rawValue, inSection: 0), NSIndexPath(forItem: LetGoUserSettings.ChangeLocation.rawValue, inSection: 0)], withRowAnimation: .Automatic)
    }

    // MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LetGoUserSettings.numberOfOptions()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(SettingsViewController.cellIdentifier, forIndexPath: indexPath) as? SettingsCell else { return UITableViewCell() }
        
        let setting = LetGoUserSettings(rawValue: indexPath.row)!
        
        cell.label.text = setting.titleForSetting()
        cell.label.textColor = setting == .LogOut ? UIColor.lightGrayColor() : UIColor.darkGrayColor()
        
        if setting == .ChangeUsername {
            cell.nameLabel.text = MyUserRepository.sharedInstance.myUser?.publicUsername
        }
        
        if setting == .ChangeLocation {
            if let myUser = MyUserRepository.sharedInstance.myUser {
                cell.nameLabel.text = myUser.postalAddress.city ?? myUser.postalAddress.countryCode
            }
        }

        if setting == .ChangePhoto {
            if let myUser = MyUserRepository.sharedInstance.myUser, let avatarUrl = myUser.avatar?.fileURL {
                cell.iconImageView.sd_setImageWithURL(avatarUrl, placeholderImage: UIImage(named: "no_photo"))
            }
            else {
                cell.iconImageView.image = UIImage(named: "no_photo")
            }
            cell.iconImageView.layer.borderColor = UIColor(rgb: 0xD8D8D8).CGColor
            cell.iconImageView.layer.borderWidth = 1
        }
        else {
            cell.iconImageView.image = setting.imageForSetting()
        }

        cell.iconImageView.contentMode = setting == .ChangePhoto ? .ScaleAspectFill : .Center
        cell.iconImageView.layer.cornerRadius = setting == .ChangePhoto ? cell.iconImageView.frame.size.width / 2.0 : 0.0
        cell.iconImageView.clipsToBounds = true
        
        return cell
    }
    
    // MARK: - UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let setting = LetGoUserSettings(rawValue: indexPath.row)!
        switch (setting) {
        case .InviteFbFriends:
            let content = FBSDKAppInviteContent()
            content.appLinkURL = NSURL(string: Constants.facebookAppLinkURL)
            
            //optionally set previewImageURL
            content.appInvitePreviewImageURL = NSURL(string: Constants.facebookAppInvitePreviewImageURL)
            
            // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
            FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
            
            let trackerEvent = TrackerEvent.appInviteFriend(EventParameterShareNetwork.Facebook)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
            
        case .ChangePhoto:
            MediaPickerManager.showImagePickerIn(self)
//        case .ChangeLocation:
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewControllerWithIdentifier("indicateLocationViewController") as! IndicateLocationViewController
//            self.navigationController?.pushViewController(vc, animated: true)
        case .ChangeUsername:
            let vc = ChangeUsernameViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .ChangeLocation:
            let vc = EditUserLocationViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .ChangePassword:
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewControllerWithIdentifier("ChangePasswordViewController") as! ChangePasswordViewController
            let vc = ChangePasswordViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case .Help:
            let vc = HelpViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .ContactUs:
            let vc = ContactViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .LogOut:
            logoutUser()
        }
    }
    
    func logoutUser() {
        // Logout
        SessionManager.sharedInstance.logout(nil)
        
        // Tracking
        let trackerEvent = TrackerEvent.logout()
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        
        TrackerProxy.sharedInstance.setUser(nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var imageFile: PFFile? = nil
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }

        // update loading UI
        self.dismissViewControllerAnimated(true, completion: nil)
        self.settingProfileImageProgressView.progress = 0.0
        self.settingProfileImageView.hidden = false
        
        // generate cropped image to 1024x1024 at most.
        if image != nil {
            if let croppedImage = image!.croppedCenteredImage(),
                let resizedImage = croppedImage.resizedImageToSize(CGSizeMake(kLetGoUserImageSquareSize, kLetGoUserImageSquareSize), interpolationQuality: CGInterpolationQuality.Medium),
                let imageData = UIImageJPEGRepresentation(resizedImage, 0.9) {
                    
                imageFile = PFFile(data: imageData)
            }
        }

//        if let actualImage = image, let croppedImage = actualImage.croppedCenteredImage(), let resizedImage = croppedImage.resizedImageToSize(CGSizeMake(kLetGoUserImageSquareSize, kLetGoUserImageSquareSize), interpolationQuality: kCGInterpolationMedium) {
//            MyUserManager.sharedInstance.updateAvatarWithImage(resizedImage) { (result: Result<File, FileUploadError>) in
//                
//        }

        // upload image.
        if imageFile == nil { // we were unable to generate the image file.
            self.settingProfileImageView.hidden = true
            self.showAutoFadingOutMessageAlert(LGLocalizedString.settingsChangeProfilePictureErrorGeneric)
        } else { // we have a valid image PFFile, now update current user's avatar with it.
            imageFile?.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success { // successfully uploaded image. Now assign it to the user and save him/her.
                    PFUser.currentUser()!["avatar"] = imageFile
                    PFUser.currentUser()!.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            // save local user image
                            self.tableView.reloadData()
                            self.settingProfileImageView.hidden = true
                            
                            let trackerEvent = TrackerEvent.profileEditEditPicture()
                            TrackerProxy.sharedInstance.trackEvent(trackerEvent)

                        } else { // unable save user with new avatar.
                            self.settingProfileImageView.hidden = true
                            self.showAutoFadingOutMessageAlert(LGLocalizedString.settingsChangeProfilePictureErrorGeneric)
                        }
                    })
                } else { // error uploading new user image.
                    self.settingProfileImageView.hidden = true
                    self.showAutoFadingOutMessageAlert(LGLocalizedString.settingsChangeProfilePictureErrorGeneric)
                }
            }, progressBlock: { (progressAsInt) -> Void in
                self.settingProfileImageProgressView.setProgress(Float(progressAsInt)/100.0, animated: true)
            })
            
            
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: FBSDKAppInviteDialogDelegate
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        
        guard let _ = results else {
            // success and no results means app invite has been cancelled via DONE in webview
            let trackerEvent = TrackerEvent.appInviteFriendCancel(EventParameterShareNetwork.Facebook)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
            return
        }
        
        if let completionGesture = results["completionGesture"] as? String {
            if completionGesture == "cancel" {
                let trackerEvent = TrackerEvent.appInviteFriendCancel(EventParameterShareNetwork.Facebook)
                TrackerProxy.sharedInstance.trackEvent(trackerEvent)
                return
            }
        }
        
        let trackerEvent = TrackerEvent.appInviteFriendComplete(EventParameterShareNetwork.Facebook)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        
        showAutoFadingOutMessageAlert(LGLocalizedString.settingsInviteFacebookFriendsOk)
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        showAutoFadingOutMessageAlert(LGLocalizedString.settingsInviteFacebookFriendsError)
    }
    
}
