//
//  PushPrePermissionsSettings.swift
//  LetGo
//
//  Created by Isaac Roldan on 7/3/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

final class PushPrePermissionsSettingsViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var firstSectionLabel: UILabel!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var secondSectionLabel: UILabel!
    @IBOutlet weak var allowNotificationsLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    
    let viewModel: PushPrePermissionsSettingsViewModel
    
    // MARK: - Lifecycle
    
    init(viewModel: PushPrePermissionsSettingsViewModel) {
        self.viewModel = viewModel
        
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            super.init(viewModel: nil, nibName: "PushPrePermissionsSettingsViewControllerMini")
        case .iPhone6, .iPhone6Plus, .unknown:
            super.init(viewModel: nil, nibName: "PushPrePermissionsSettingsViewController")
        }
        
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        setupUI()
        setupStrings()
    }
    
    
    // MARK: - UI
    
    func setupUI() {
        yesButton.setPrimaryStyle()
        
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            titleLabel.font = StyleHelper.tourNotificationsTitleMiniFont
            subtitleLabel.font = StyleHelper.tourNotificationsSubtitleMiniFont
            firstSectionLabel.font = StyleHelper.tourNotificationsSubtitleMiniFont
            secondSectionLabel.font = StyleHelper.tourNotificationsSubtitleMiniFont
            notificationsLabel.font = StyleHelper.notificationsSettingsCellTextMiniFont
            allowNotificationsLabel.font = StyleHelper.notificationsSettingsCellTextMiniFont
        case .iPhone6, .iPhone6Plus, .unknown:
            titleLabel.font = StyleHelper.tourNotificationsTitleFont
            subtitleLabel.font = StyleHelper.tourNotificationsSubtitleFont
            firstSectionLabel.font = StyleHelper.tourNotificationsSubtitleFont
            secondSectionLabel.font = StyleHelper.tourNotificationsSubtitleFont
            notificationsLabel.font = StyleHelper.notificationsSettingsCellTextFont
            allowNotificationsLabel.font = StyleHelper.notificationsSettingsCellTextFont
        }
    }
    
    func setupStrings() {
        titleLabel.text = LGLocalizedString.notificationsPermissionsSettingsTitle
        subtitleLabel.text = LGLocalizedString.notificationsPermissionsSettingsSubtitle
        firstSectionLabel.attributedText = firstSectionAttributedTitle()
        notificationsLabel.text = LGLocalizedString.notificationsPermissionsSettingsCell1
        secondSectionLabel.attributedText = secondSectionAttributedTitle()
        allowNotificationsLabel.text = LGLocalizedString.notificationsPermissionsSettingsCell2
        yesButton.setTitle(LGLocalizedString.notificationsPermissionsSettingsYesButton, forState: .Normal)
    }
    
    
    func firstSectionAttributedTitle() -> NSAttributedString {
        let attributes = [NSForegroundColorAttributeName: StyleHelper.primaryColor]
        let title = NSMutableAttributedString(string: "1. ", attributes: attributes)
        let text = NSAttributedString(string: LGLocalizedString.notificationsPermissionsSettingsSection1, attributes: nil)
        title.appendAttributedString(text)
        return title
    }
    
    func secondSectionAttributedTitle() -> NSAttributedString {
        let attributes = [NSForegroundColorAttributeName: StyleHelper.primaryColor]
        let title = NSMutableAttributedString(string: "2. ", attributes: attributes)
        let text = NSAttributedString(string: LGLocalizedString.notificationsPermissionsSettingsSection2, attributes: nil)
        title.appendAttributedString(text)
        return title
    }
    
    
    // MARK: - Actions
    
    @IBAction func yesButtonPressed(sender: AnyObject) {
        PushPermissionsManager.sharedInstance.openPushNotificationSettings()
        viewModel.userDidTapYesButton()
        close()
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        viewModel.userDidTapNoButton()
        close()
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}