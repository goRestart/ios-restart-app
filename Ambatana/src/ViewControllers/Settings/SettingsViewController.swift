//
//  SettingsViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 13/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import FBSDKShareKit
import RxSwift
import CollectionVariable

class SettingsViewController: BaseViewController {

    // constants
    private static let cellIdentifier = "SettingsCell"

    // outlets & buttons
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingProfileImageView: UIView!
    @IBOutlet weak var settingProfileImageLabel: UILabel!
    @IBOutlet weak var settingProfileImageProgressView: UIProgressView!

    private let viewModel: SettingsViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "SettingsViewController")
        self.viewModel.delegate = self
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAccessibilityIds()
        setupRx()
    }

    deinit {
        /* @ahl: This is because of a crash in iOS8; logout+login, check: https://ambatana.atlassian.net/browse/ABIOS-1639
           Explanation here:
           http://stackoverflow.com/questions/5499913/pop-to-root-view-controller-without-animation-crash-for-the-table-view */
        tableView.delegate = nil
        tableView.dataSource = nil
    }


    // MARK: - Private

    private func setupUI() {
        settingProfileImageLabel.text = LGLocalizedString.settingsChangeProfilePictureLoading
        settingProfileImageView.hidden = true
        setNavBarTitle(LGLocalizedString.settingsTitle)

        let cellNib = UINib(nibName: "SettingsCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: SettingsCell.reusableID)
        tableView.rowHeight = 60
    }

    private func setupAccessibilityIds() {
        tableView.accessibilityId = .SettingsList
    }

    private func setupRx() {
        viewModel.avatarLoadingProgress.asObservable().bindNext { [weak self] progress in
            if let progress = progress {
                onMainThread { [weak self] in
                    self?.settingProfileImageProgressView.setProgress(progress, animated: true)
                }
                self?.settingProfileImageView.hidden = false
            } else {
                self?.settingProfileImageView.hidden = true
            }
        }.addDisposableTo(disposeBag)

        viewModel.sections.asObservable().bindNext { [weak self] _ in
            self?.tableView.reloadData()
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - TableView

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitle(section)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsCount(section)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(SettingsCell.reusableID, forIndexPath: indexPath)
            as? SettingsCell else { return UITableViewCell() }
        guard let setting = viewModel.settingAtSection(indexPath.section, index: indexPath.row) else { return UITableViewCell() }
        cell.setupWithSetting(setting)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        viewModel.settingSelectedAtSection(indexPath.section, index: indexPath.row)
    }
}


// MARK: - SettingsViewModelDelegate 

extension SettingsViewController: SettingsViewModelDelegate {
    func vmOpenImagePick() {
        MediaPickerManager.showImagePickerIn(self)
    }

    func vmOpenFbAppInvite(content: FBSDKAppInviteContent) {
        FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
    }
}


// MARK: - Image Pick

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        self.dismissViewControllerAnimated(true, completion: nil)
        guard let theImage = image else { return }
        viewModel.imageSelected(theImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - FBSDKAppInviteDialogDelegate

extension SettingsViewController: FBSDKAppInviteDialogDelegate {

    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        guard let _ = results else {
            viewModel.fbAppInviteCancel()
            return
        }
        if let completionGesture = results["completionGesture"] as? String where completionGesture == "cancel"{
            viewModel.fbAppInviteCancel()
            return
        }
        viewModel.fbAppInviteDone()
    }

    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        viewModel.fbAppInviteFailed()
    }
}


// MARK: - LetGoSetting UI

extension LetGoSetting {
    var title: String {
        switch (self) {
        case .InviteFbFriends:
            return LGLocalizedString.settingsInviteFacebookFriendsButton
        case .ChangePhoto:
            return LGLocalizedString.settingsChangeProfilePictureButton
        case .ChangeUsername:
            return LGLocalizedString.settingsChangeUsernameButton
        case .ChangeLocation:
            return LGLocalizedString.settingsChangeLocationButton
        case .CreateCommercializer:
            return LGLocalizedString.commercializerCreateFromSettings
        case .ChangePassword:
            return LGLocalizedString.settingsChangePasswordButton
        case .Help:
            return LGLocalizedString.settingsHelpButton
        case .LogOut:
            return LGLocalizedString.settingsLogoutButton
        }
    }

    var image: UIImage? {
        switch (self) {
        case .InviteFbFriends:
            return UIImage(named: "ic_fb_settings")
        case .ChangeUsername:
            return UIImage(named: "ic_change_username")
        case .ChangeLocation:
            return UIImage(named: "ic_location_edit")
        case .CreateCommercializer:
            return UIImage(named: "ic_play_video")
        case .ChangePassword:
            return UIImage(named: "edit_profile_password")
        case .Help:
            return UIImage(named: "ic_help")
        case .LogOut:
            return UIImage(named: "edit_profile_logout")
        case let .ChangePhoto(placeholder,_):
            return placeholder
        }
    }

    var imageURL: NSURL? {
        switch self {
        case let .ChangePhoto(_,avatarUrl):
            return avatarUrl
        default:
            return nil
        }
    }

    var imageRounded: Bool {
        switch self {
        case .ChangePhoto:
            return true
        default:
            return false
        }
    }

    var textColor: UIColor {
        switch (self) {
        case .LogOut:
            return UIColor.lightGrayColor()
        case .CreateCommercializer:
            return UIColor.primaryColor
        default:
            return UIColor.darkGrayColor()
        }
    }

    var textValue: String? {
        switch self {
        case let .ChangeUsername(name):
            return name
        case let .ChangeLocation(location):
            return location
        default:
            return nil
        }
    }

    var showsDisclosure: Bool {
        switch self {
        case .LogOut:
            return false
        default:
            return true
        }
    }
}
