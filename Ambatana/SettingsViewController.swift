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
            return translate("change_photo")
        //case .ChangeLocation:
        //    return translate("change_my_location")
        case .ChangePassword:
            return translate("change_password")
        case .LogOut:
            return translate("logout")
        }
    }
    
    func imageForSetting() -> UIImage? {
        switch (self) {
        case .ChangePhoto:
            return ConfigurationManager.sharedInstance.userProfileImage ?? UIImage(named: "no_photo")
        //case .ChangeLocation:
        //    return UIImage(named: "edit_profile_location")
        case .ChangePassword:
            return UIImage(named: "edit_profile_password")
        case .LogOut:
            return UIImage(named: "edit_profile_logout")
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
        settingProfileImageLabel.text = translate("setting_profile_image")
        
        // appearance
        settingProfileImageView.hidden = true
        setLetGoNavigationBarStyle(title: translate("settings"))
        
        // tableview
        let cellNib = UINib(nibName: "SettingsCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: SettingsViewController.cellIdentifier)
        tableView.rowHeight = 60
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        cell.iconImageView.image = setting.imageForSetting()
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
            NSNotificationCenter.defaultCenter().postNotificationName(kLetGoLogoutImminentNotification, object: nil)
            logoutUser()
        }
    }
    
    func logoutUser() {
        
//        PFUser.logOut()
        ConfigurationManager.sharedInstance.logOutUser()
        
        MyUserManager.sharedInstance.logout { (result: Result<Nil, UserLogOutServiceError>) in
            if let tabBarCtl = self.tabBarController as? TabBarController {
                tabBarCtl.switchToTab(.Home)
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // Tracking
        TrackingHelper.trackEvent(.Logout, parameters: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    func showImageSourceSelection() {
        if iOSVersionAtLeast("8.0") {
            let alert = UIAlertController(title: translate("choose_image_source"), message: translate("choose_image_source_description"), preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: translate("camera"), style: .Default, handler: { (alertAction) -> Void in
                self.openImagePickerWithSource(.Camera)
            }))
            alert.addAction(UIAlertAction(title: translate("photo_library"), style: .Default, handler: { (alertAction) -> Void in
                self.openImagePickerWithSource(.PhotoLibrary)
            }))
            alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let actionSheet = UIActionSheet()
            actionSheet.delegate = self
            actionSheet.title = translate("choose_image_source")
            actionSheet.addButtonWithTitle(translate("camera"))
            actionSheet.addButtonWithTitle(translate("photo_library"))
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

        // upload image.
        if imageFile == nil { // we were unable to generate the image file.
            self.settingProfileImageView.hidden = true
            self.showAutoFadingOutMessageAlert(translate("error_setting_profile_image"))
        } else { // we have a valid image PFFile, now update current user's avatar with it.
            imageFile?.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success { // successfully uploaded image. Now assign it to the user and save him/her.
                    PFUser.currentUser()!["avatar"] = imageFile
                    PFUser.currentUser()!.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            // save local user image
                            ConfigurationManager.sharedInstance.userProfileImage = UIImage(data: imageFile!.getData()!)
                            self.tableView.reloadData()
                            self.settingProfileImageView.hidden = true
                        } else { // unable save user with new avatar.
                            self.settingProfileImageView.hidden = true
                            self.showAutoFadingOutMessageAlert(translate("error_setting_profile_image"))
                        }
                    })
                } else { // error uploading new user image.
                    self.settingProfileImageView.hidden = true
                    self.showAutoFadingOutMessageAlert(translate("error_setting_profile_image"))
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
