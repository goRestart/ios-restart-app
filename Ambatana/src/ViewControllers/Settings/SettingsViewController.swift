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
        setupRx()
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

        viewModel.settingsChanges.bindNext { [weak self] change in
            self?.tableView.handleCollectionChange(change, animated: false)
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - TableView

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsCount
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(SettingsCell.reusableID, forIndexPath: indexPath)
            as? SettingsCell else { return UITableViewCell() }
        guard let setting = viewModel.settingAtIndex(indexPath.row) else { return UITableViewCell() }
        cell.setupWithSetting(setting)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        viewModel.settingSelectedAtIndex(indexPath.row)
    }
}


// MARK: - SettingsViewModelDelegate 

extension SettingsViewController: SettingsViewModelDelegate {
    func vmOpenSettingsDetailVC(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }

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


extension UITableView {
    func handleCollectionChange<T>(change: CollectionChange<T>, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        beginUpdates()
        handleChange(change)
        endUpdates()
    }

    private func handleChange<T>(change: CollectionChange<T>, animated: Bool = true) {
        switch change {
        case .Remove(let index, _):
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            deleteRowsAtIndexPaths([indexPath], withRowAnimation: animated ? .Automatic : .None)
        case .Insert(let index, _):
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            insertRowsAtIndexPaths([indexPath], withRowAnimation: animated ? .Automatic : .None)
        case .Composite(let changes):
            changes.forEach { [weak self] change in
                self?.handleChange(change)
            }
        }
    }
}
