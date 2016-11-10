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
        view.backgroundColor = UIColor.grayBackground
        settingProfileImageLabel.text = LGLocalizedString.settingsChangeProfilePictureLoading
        settingProfileImageView.hidden = true
        setNavBarTitle(LGLocalizedString.settingsTitle)

        let cellNib = UINib(nibName: SettingsCell.reusableID, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: SettingsCell.reusableID)
        let logoutCellNib = UINib(nibName: SettingsLogoutCell.reusableID, bundle: nil)
        tableView.registerNib(logoutCellNib, forCellReuseIdentifier: SettingsLogoutCell.reusableID)
        let infoCellNib = UINib(nibName: SettingsInfoCell.reusableID, bundle: nil)
        tableView.registerNib(infoCellNib, forCellReuseIdentifier: SettingsInfoCell.reusableID)
        let switchCellNib = UINib(nibName: SettingsSwitchCell.reusableID, bundle: nil)
        tableView.registerNib(switchCellNib, forCellReuseIdentifier: SettingsSwitchCell.reusableID)
        tableView.backgroundColor = UIColor.grayBackground
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
            self?.tableView?.reloadData()
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - TableView

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    private static let headerHeight: CGFloat = 50
    private static let emptyHeaderHeight: CGFloat = 30

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let title = viewModel.sectionTitle(section)
        return title.isEmpty ? SettingsViewController.emptyHeaderHeight : SettingsViewController.headerHeight
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = viewModel.sectionTitle(section)
        guard !title.isEmpty else {
            let container = UIView()
            container.backgroundColor = UIColor.grayBackground
            if section > 0 {
                let topSeparator = UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: LGUIKitConstants.onePixelSize))
                topSeparator.backgroundColor = UIColor.grayLight
                container.addSubview(topSeparator)
            }
            return container
        }
        let container = UIView()
        container.backgroundColor = UIColor.grayBackground
        if section > 0 {
            let topSeparator = UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: LGUIKitConstants.onePixelSize))
            topSeparator.backgroundColor = UIColor.grayLight
            container.addSubview(topSeparator)
        }
        let label = UILabel(frame: CGRect(x: 12, y: 28, width: tableView.width, height: 15))
        label.text = title.uppercase
        label.font = UIFont.systemRegularFont(size: 13)
        label.textColor = UIColor.gray
        label.sizeToFit()
        container.addSubview(label)
        let bottomSeparator = UIView(frame: CGRect(x: 0, y: SettingsViewController.headerHeight-LGUIKitConstants.onePixelSize,
            width: tableView.width, height: LGUIKitConstants.onePixelSize))
        bottomSeparator.backgroundColor = UIColor.grayLight
        container.addSubview(bottomSeparator)
        return container
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsCount(section)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let setting = viewModel.settingAtSection(indexPath.section, index: indexPath.row) else { return 0 }
        return setting.cellHeight
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let setting = viewModel.settingAtSection(indexPath.section, index: indexPath.row) else { return UITableViewCell() }
        switch setting {
        case .LogOut:
            guard let cell = tableView.dequeueReusableCellWithIdentifier(SettingsLogoutCell.reusableID, forIndexPath: indexPath)
                as? SettingsLogoutCell else { return UITableViewCell() }
            return cell
        case .VersionInfo:
            guard let cell = tableView.dequeueReusableCellWithIdentifier(SettingsInfoCell.reusableID, forIndexPath: indexPath)
                as? SettingsInfoCell else { return UITableViewCell() }
            cell.refreshData()
            return cell
        case .MarketingNotifications:
            guard let cell = tableView.dequeueReusableCellWithIdentifier(SettingsSwitchCell.reusableID, forIndexPath: indexPath)
                as? SettingsSwitchCell else { return UITableViewCell() }
            cell.setupWithSetting(setting)
            cell.showBottomBorder = indexPath.row < viewModel.settingsCount(indexPath.section) - 1
            return cell
        default:
            guard let cell = tableView.dequeueReusableCellWithIdentifier(SettingsCell.reusableID, forIndexPath: indexPath)
                as? SettingsCell else { return UITableViewCell() }
            cell.setupWithSetting(setting)
            cell.showBottomBorder = indexPath.row < viewModel.settingsCount(indexPath.section) - 1
            return cell
        }
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

    var cellHeight: CGFloat {
        switch self {
        case .InviteFbFriends, .ChangePhoto, .ChangeUsername, .ChangeLocation, .CreateCommercializer, .ChangePassword,
             .Help, .MarketingNotifications:
            return 50
        case .LogOut:
            return 44
        case .VersionInfo:
            return 30
        }
    }
}
