//
//  SettingsViewController.swift
//  Ambatana
//
//  Created by Nacho on 13/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kAmbatanaSettingsTableCellImageTag = 1
private let kAmbatanaSettingsTableCellTitleTag = 2

private let kAmbatanaUserImageSquareSize: CGFloat = 1024

enum AmbatanaUserSettings: Int {
    case ChangePhoto = 0, ChangeLocation = 1, ChangePassword = 2, FavoriteCategories = 3, LogOut = 4
    
    static func numberOfOptions() -> Int { return 5 }
    
    func titleForSetting() -> String {
        switch (self) {
        case .ChangePhoto:
            return translate("change_photo")
        case .ChangeLocation:
            return translate("change_my_location")
        case .ChangePassword:
            return translate("change_password")
        case .FavoriteCategories:
            return translate("favorite_categories")
        case .LogOut:
            return translate("logout")
        }
    }
    
    func imageForSetting() -> UIImage? {
        switch (self) {
        case .ChangePhoto:
            return ConfigurationManager.sharedInstance.userProfileImage ?? UIImage(named: "no_photo")
        case .ChangeLocation:
            return UIImage(named: "edit_profile_location")
        case .ChangePassword:
            return UIImage(named: "edit_profile_password")
        case .FavoriteCategories:
            return UIImage(named: "edit_profile_favorited")
        case .LogOut:
            return UIImage(named: "edit_profile_logout")
        }
    }
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // outlets & buttons
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setAmbatanaNavigationBarStyle(title: translate("settings"), includeBackArrow: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AmbatanaUserSettings.numberOfOptions()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AmbatanaSettingsCell", forIndexPath: indexPath) as UITableViewCell
        let setting = AmbatanaUserSettings(rawValue: indexPath.row)!
        
        // configure cell
        if let titleLabel = cell.viewWithTag(kAmbatanaSettingsTableCellTitleTag) as? UILabel {
            titleLabel.text = setting.titleForSetting()
            titleLabel.textColor = setting == .LogOut ? UIColor.lightGrayColor() : UIColor.darkGrayColor()
        }
        
        if let imageView = cell.viewWithTag(kAmbatanaSettingsTableCellImageTag) as? UIImageView {
            imageView.image = setting.imageForSetting()
            imageView.contentMode = setting == .ChangePhoto ? .ScaleAspectFill : .Center
            imageView.layer.cornerRadius = setting == .ChangePhoto ? imageView.frame.size.width / 2.0 : 0.0
            imageView.clipsToBounds = true
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let setting = AmbatanaUserSettings(rawValue: indexPath.row)!
        switch (setting) {
        case .ChangePhoto:
            showImageSourceSelection()
        case .ChangeLocation:
            performSegueWithIdentifier("ChangeLocation", sender: nil)
        case .ChangePassword:
            if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
                // we are linked with Facebook, so we don't actually have a password.
                self.showAutoFadingOutMessageAlert(translate("cant_change_facebook_password"))
            } else {
                performSegueWithIdentifier("ChangePassword", sender: nil)
            }
        case .FavoriteCategories:
            performSegueWithIdentifier("SetFavoriteCategories", sender: nil)
        case .LogOut:
            logoutUser()
        }
    }
    
    func logoutUser() {
        PFUser.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    func showImageSourceSelection() {
        let alert = UIAlertController(title: translate("choose_image_source"), message: translate("choose_image_source_description"), preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: translate("camera"), style: .Default, handler: { (alertAction) -> Void in
            self.openImagePickerWithSource(.Camera)
        }))
        alert.addAction(UIAlertAction(title: translate("photo_library"), style: .Default, handler: { (alertAction) -> Void in
            self.openImagePickerWithSource(.PhotoLibrary)
        }))
        alert.addAction(UIAlertAction(title: translate("cancel"), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
        
        self.showLoadingMessageAlert(customMessage: translate("setting_profile_image"))
        if image != nil {
            if let croppedImage = image!.cropToSquare() {
                if let resizedImage = croppedImage.resize(CGSizeMake(kAmbatanaUserImageSquareSize, kAmbatanaUserImageSquareSize), contentMode: .ScaleAspectFill) {
                    // update parse DDBB
                    let imageData = UIImageJPEGRepresentation(croppedImage, 0.9)
                    imageFile = PFFile(data: imageData)
                }
            }
        }

        if imageFile == nil { // we were unable to generate the image file.
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.showAutoFadingOutMessageAlert(translate("error_setting_profile_image"))
            })
        } else { // we have a valid image PFFile, now update current user's avatar with it.
            PFUser.currentUser()["avatar"] = imageFile
            PFUser.currentUser().saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    // save local user image
                    ConfigurationManager.sharedInstance.userProfileImage = UIImage(data: imageFile!.getData())
                    self.tableView.reloadData()
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        self.showAutoFadingOutMessageAlert(translate("error_setting_profile_image"))
                    })
                }
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
