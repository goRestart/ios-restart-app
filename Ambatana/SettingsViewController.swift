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

private let kLetGoSettingsTableCellImageTag = 1
private let kLetGoSettingsTableCellTitleTag = 2

private let kLetGoUserImageSquareSize: CGFloat = 1024

enum LetGoUserSettings: Int {
    //case ChangePhoto = 0, ChangeLocation = 1, ChangePassword = 2, LogOut = 3
    case ChangePhoto = 0, ChangePassword = 1, LogOut = 2
    
    static func numberOfOptions() -> Int { return 3 }
    
    func titleForSetting() -> String {
        switch (self) {
        case .ChangePhoto:
            return NSLocalizedString("settings_change_profile_picture_button", comment: "")
        case .ChangePassword:
            return NSLocalizedString("settings_change_password_button", comment: "")
        case .LogOut:
            return NSLocalizedString("settings_logout_button", comment: "")
        }
    }
    
    func imageForSetting() -> UIImage? {
        switch (self) {
        case .ChangePassword:
            return UIImage(named: "edit_profile_password")
        case .LogOut:
            return UIImage(named: "edit_profile_logout")
        default:
            return nil
        }
    }
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {

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

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // internationalization
        settingProfileImageLabel.text = NSLocalizedString("settings_change_profile_picture_loading", comment: "")
        
        // appearance
        settingProfileImageView.hidden = true
        setLetGoNavigationBarStyle(title: NSLocalizedString("settings_title", comment: ""))
        
        // tableview
        let cellNib = UINib(nibName: "SettingsCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: SettingsViewController.cellIdentifier)
        tableView.rowHeight = 60
    }
    
    // MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LetGoUserSettings.numberOfOptions()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SettingsViewController.cellIdentifier, forIndexPath: indexPath) as! SettingsCell
        let setting = LetGoUserSettings(rawValue: indexPath.row)!
        
        cell.label.text = setting.titleForSetting()
        cell.label.textColor = setting == .LogOut ? UIColor.lightGrayColor() : UIColor.darkGrayColor()
        
        if setting == .ChangePhoto {
            if let myUser = MyUserManager.sharedInstance.myUser(), let avatarUrl = myUser.avatar?.fileURL {
                cell.iconImageView.sd_setImageWithURL(avatarUrl, placeholderImage: UIImage(named: "no_photo"))
            }
            else {
                cell.iconImageView.image = UIImage(named: "no_photo")
            }
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
        case .ChangePhoto:
            showImageSourceSelection()
//        case .ChangeLocation:
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewControllerWithIdentifier("indicateLocationViewController") as! IndicateLocationViewController
//            self.navigationController?.pushViewController(vc, animated: true)
        case .ChangePassword:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("ChangePasswordViewController") as! ChangePasswordViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case .LogOut:
            logoutUser()
        }
    }
    
    func logoutUser() {
        // Logout
        MyUserManager.sharedInstance.logout { (result: Result<Nil, UserLogOutServiceError>) in }
        
        // Tracking
        TrackingHelper.trackEvent(.Logout, parameters: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    func showImageSourceSelection() {
        if iOSVersionAtLeast("8.0") {
            let alert = UIAlertController(title: NSLocalizedString("settings_image_source_title", comment: ""), message: nil, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("settings_image_source_camera_button", comment: ""), style: .Default, handler: { (alertAction) -> Void in
                self.openImagePickerWithSource(.Camera)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("settings_image_source_camera_roll_button", comment: ""), style: .Default, handler: { (alertAction) -> Void in
                self.openImagePickerWithSource(.PhotoLibrary)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("settings_image_source_cancel_button", comment: ""), style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let actionSheet = UIActionSheet()
            actionSheet.delegate = self
            actionSheet.title = NSLocalizedString("settings_image_source_title", comment: "")
            actionSheet.addButtonWithTitle(NSLocalizedString("settings_image_source_camera_button", comment: ""))
            actionSheet.addButtonWithTitle(NSLocalizedString("settings_image_source_camera_roll_button", comment: ""))
            actionSheet.showInView(self.view)
        }
        
    }
    
    // iOS 7 compatibility action sheet for image source selection
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 0 { self.openImagePickerWithSource(.Camera) }
        else { self.openImagePickerWithSource(.PhotoLibrary) }
    }
    
    func openImagePickerWithSource(source: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var imageFile: PFFile? = nil
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }

        // update loading UI
        self.dismissViewControllerAnimated(true, completion: nil)
        self.settingProfileImageProgressView.progress = 0.0
        self.settingProfileImageView.hidden = false
        
        // generate cropped image to 1024x1024 at most.
        if image != nil {
            if let croppedImage = image!.croppedCenteredImage() {
                if let resizedImage = croppedImage.resizedImageToSize(CGSizeMake(kLetGoUserImageSquareSize, kLetGoUserImageSquareSize), interpolationQuality: kCGInterpolationMedium) {
                    // update parse DDBB
                    let imageData = UIImageJPEGRepresentation(croppedImage, 0.9)
                    imageFile = PFFile(data: imageData)
                }
            }
        }

//        if let actualImage = image, let croppedImage = actualImage.croppedCenteredImage(), let resizedImage = croppedImage.resizedImageToSize(CGSizeMake(kLetGoUserImageSquareSize, kLetGoUserImageSquareSize), interpolationQuality: kCGInterpolationMedium) {
//            MyUserManager.sharedInstance.updateAvatarWithImage(resizedImage) { (result: Result<File, FileUploadError>) in
//                
//        }

        // upload image.
        if imageFile == nil { // we were unable to generate the image file.
            self.settingProfileImageView.hidden = true
            self.showAutoFadingOutMessageAlert(NSLocalizedString("settings_change_profile_picture_error_generic", comment: ""))
        } else { // we have a valid image PFFile, now update current user's avatar with it.
            imageFile?.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success { // successfully uploaded image. Now assign it to the user and save him/her.
                    PFUser.currentUser()!["avatar"] = imageFile
                    PFUser.currentUser()!.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            // save local user image
                            self.tableView.reloadData()
                            self.settingProfileImageView.hidden = true
                        } else { // unable save user with new avatar.
                            self.settingProfileImageView.hidden = true
                            self.showAutoFadingOutMessageAlert(NSLocalizedString("settings_change_profile_picture_error_generic", comment: ""))
                        }
                    })
                } else { // error uploading new user image.
                    self.settingProfileImageView.hidden = true
                    self.showAutoFadingOutMessageAlert(NSLocalizedString("settings_change_profile_picture_error_generic", comment: ""))
                }
            }, progressBlock: { (progressAsInt) -> Void in
                self.settingProfileImageProgressView.setProgress(Float(progressAsInt)/100.0, animated: true)
            })
            
            
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Navigation.
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ilvc = segue.destinationViewController as? IndicateLocationViewController {
            ilvc.allowGoingBack = true
        }
    }
}
