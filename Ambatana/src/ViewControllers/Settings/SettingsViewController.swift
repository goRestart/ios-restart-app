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

class SettingsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingProfileImageView: UIView!
    @IBOutlet weak var settingProfileImageLabel: UILabel!
    @IBOutlet weak var settingProfileImageProgressView: UIProgressView!

    fileprivate let viewModel: SettingsViewModel
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
        settingProfileImageView.isHidden = true
        setNavBarTitle(LGLocalizedString.settingsTitle)
    
        let cellNib = UINib(nibName: SettingsCell.reusableID, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: SettingsCell.reusableID)
        let logoutCellNib = UINib(nibName: SettingsLogoutCell.reusableID, bundle: nil)
        tableView.register(logoutCellNib, forCellReuseIdentifier: SettingsLogoutCell.reusableID)
        let infoCellNib = UINib(nibName: SettingsInfoCell.reusableID, bundle: nil)
        tableView.register(infoCellNib, forCellReuseIdentifier: SettingsInfoCell.reusableID)
        let switchCellNib = UINib(nibName: SettingsSwitchCell.reusableID, bundle: nil)
        tableView.register(switchCellNib, forCellReuseIdentifier: SettingsSwitchCell.reusableID)
        tableView.backgroundColor = UIColor.grayBackground
        tableView.contentInset.bottom = 15
        automaticallyAdjustsScrollViewInsets = false
    }

    private func setupAccessibilityIds() {
        tableView.accessibilityId = .settingsList
    }

    private func setupRx() {
        viewModel.avatarLoadingProgress.asObservable().bindNext { [weak self] progress in
            if let progress = progress {
                onMainThread { [weak self] in
                    self?.settingProfileImageProgressView.setProgress(progress, animated: true)
                }
                self?.settingProfileImageView.isHidden = false
            } else {
                self?.settingProfileImageView.isHidden = true
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionCount
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let title = viewModel.sectionTitle(section)
        return title.isEmpty ? SettingsViewController.emptyHeaderHeight : SettingsViewController.headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsCount(section)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let setting = viewModel.settingAtSection(indexPath.section, index: indexPath.row) else { return 0 }
        return setting.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let setting = viewModel.settingAtSection(indexPath.section, index: indexPath.row) else { return UITableViewCell() }
        switch setting {
        case .logOut:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsLogoutCell.reusableID, for: indexPath)
                as? SettingsLogoutCell else { return UITableViewCell() }
            return cell
        case .versionInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsInfoCell.reusableID, for: indexPath)
                as? SettingsInfoCell else { return UITableViewCell() }
            cell.refreshData()
            return cell
        case .marketingNotifications:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsSwitchCell.reusableID, for: indexPath)
                as? SettingsSwitchCell else { return UITableViewCell() }
            cell.setupWithSetting(setting)
            cell.showBottomBorder = indexPath.row < viewModel.settingsCount(indexPath.section) - 1
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reusableID, for: indexPath)
                as? SettingsCell else { return UITableViewCell() }
            cell.setupWithSetting(setting)
            cell.showBottomBorder = indexPath.row < viewModel.settingsCount(indexPath.section) - 1
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.settingSelectedAtSection(indexPath.section, index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Grouped tableview need empty footer to avoid default footer.
        return LGUIKitConstants.onePixelSize
    }
}


// MARK: - SettingsViewModelDelegate 

extension SettingsViewController: SettingsViewModelDelegate {
    func vmOpenImagePick() {
        MediaPickerManager.showImagePickerIn(self)
    }
}


// MARK: - Image Pick

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        self.dismiss(animated: true, completion: nil)
        guard let theImage = image else { return }
        viewModel.imageSelected(theImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - FBSDKAppInviteDialogDelegate

extension SettingsViewController: FBSDKAppInviteDialogDelegate {

    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable: Any]!) {
        guard let _ = results else {
            viewModel.fbAppInviteCancel()
            return
        }
        if let completionGesture = results["completionGesture"] as? String, completionGesture == "cancel"{
            viewModel.fbAppInviteCancel()
            return
        }
        viewModel.fbAppInviteDone()
    }

    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        viewModel.fbAppInviteFailed()
    }
}


// MARK: - LetGoSetting UI

extension LetGoSetting {

    var cellHeight: CGFloat {
        switch self {
        case .inviteFbFriends, .changePhoto, .changeUsername, .changeEmail, .changeLocation, .changePassword,
             .help, .marketingNotifications:
            return 50
        case .logOut:
            return 44
        case .versionInfo:
            return 30
        }
    }
}
