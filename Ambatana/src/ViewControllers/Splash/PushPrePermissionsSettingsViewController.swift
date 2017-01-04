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

    var completion: (() -> ())?

    let viewModel: PushPrePermissionsSettingsViewModel
    
    // MARK: - Lifecycle
    
    init(viewModel: PushPrePermissionsSettingsViewModel) {
        self.viewModel = viewModel
        
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            super.init(viewModel: viewModel, nibName: "PushPrePermissionsSettingsViewControllerMini",
                       statusBarStyle: .lightContent)
        case .iPhone6, .iPhone6Plus, .biggerUnknown:
            super.init(viewModel: viewModel, nibName: "PushPrePermissionsSettingsViewController",
                       statusBarStyle: .lightContent)
        }
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
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
        yesButton.setStyle(.primary(fontSize: .medium))
        
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            firstSectionLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            secondSectionLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            notificationsLabel.font = UIFont.notificationsSettingsCellTextMiniFont
            allowNotificationsLabel.font = UIFont.notificationsSettingsCellTextMiniFont
        case .iPhone6, .iPhone6Plus, .biggerUnknown:
            titleLabel.font = UIFont.tourNotificationsTitleFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleFont
            firstSectionLabel.font = UIFont.tourNotificationsSubtitleFont
            secondSectionLabel.font = UIFont.tourNotificationsSubtitleFont
            notificationsLabel.font = UIFont.notificationsSettingsCellTextFont
            allowNotificationsLabel.font = UIFont.notificationsSettingsCellTextFont
        }
    }
    
    func setupStrings() {
        titleLabel.text = viewModel.title
        subtitleLabel.text = LGLocalizedString.notificationsPermissionsSettingsSubtitle
        firstSectionLabel.attributedText = firstSectionAttributedTitle()
        notificationsLabel.text = LGLocalizedString.notificationsPermissionsSettingsCell1
        secondSectionLabel.attributedText = secondSectionAttributedTitle()
        allowNotificationsLabel.text = LGLocalizedString.notificationsPermissionsSettingsCell2
        yesButton.setTitle(LGLocalizedString.notificationsPermissionsSettingsYesButton, for: UIControlState())
    }
    
    
    func firstSectionAttributedTitle() -> NSAttributedString {
        let attributes = [NSForegroundColorAttributeName: UIColor.primaryColor]
        let title = NSMutableAttributedString(string: "1. ", attributes: attributes)
        let t = NSAttributedString(string: LGLocalizedString.notificationsPermissionsSettingsSection1, attributes: nil)
        title.append(t)
        return title
    }
    
    func secondSectionAttributedTitle() -> NSAttributedString {
        let attributes = [NSForegroundColorAttributeName: UIColor.primaryColor]
        let title = NSMutableAttributedString(string: "2. ", attributes: attributes)
        let t = NSAttributedString(string: LGLocalizedString.notificationsPermissionsSettingsSection2, attributes: nil)
        title.append(t)
        return title
    }
    
    
    // MARK: - Actions
    
    @IBAction func yesButtonPressed(_ sender: AnyObject) {
        PushPermissionsManager.sharedInstance.openPushNotificationSettings()
        viewModel.userDidTapYesButton()
        close()
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.userDidTapNoButton()
        close()
    }
    
    func close() {
        dismiss(animated: true, completion: completion)
    }
}
