//
//  TourNotificationsViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum DeviceFamily: Int {
    case iPhone4 = 480
    case iPhone5 = 568
    case iPhone6 = 667
    case iPhone6Plus = 736
}


final class TourNotificationsViewController: BaseViewController {
    let viewModel: TourNotificationsViewModel

    @IBOutlet weak var notifyButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iphoneRightHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var notificationMessageLabel: UILabel!
    
    var family: DeviceFamily = {
        let height = UIScreen.mainScreen().bounds.height
        return DeviceFamily.init(rawValue: Int(height))!
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: TourNotificationsViewModel) {
        self.viewModel = viewModel
        
        switch family {
        case .iPhone4:
            super.init(viewModel: viewModel, nibName: "TourNotificationsViewControllerMini")
        case .iPhone5, .iPhone6, .iPhone6Plus:
            super.init(viewModel: viewModel, nibName: "TourNotificationsViewController")
        }
        UIDevice.currentDevice().model
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    
    // MARK: - IBActions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        noButtonPressed(sender)
    }
   
    @IBAction func noButtonPressed(sender: AnyObject) {
        // show location
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func yesButtonPressed(sender: AnyObject) {
        PushPermissionsManager.sharedInstance.showPushPermissionsAlertFromViewController(self, prePermissionType: PrePermissionType.Onboarding)
        // Show location
    }
    
    
    // MARK: - UI
    
    func setupUI() {
        notifyButton.backgroundColor = StyleHelper.primaryColor
        notifyButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        notifyButton.tintColor = UIColor.whiteColor()
        notifyButton.titleLabel?.font = StyleHelper.tourButtonFont
        
        noButton.backgroundColor = UIColor.clearColor()
        noButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        noButton.layer.borderWidth = 1
        noButton.layer.borderColor = UIColor.whiteColor().CGColor
        noButton.tintColor = UIColor.whiteColor()
        noButton.titleLabel?.font = StyleHelper.tourButtonFont
        noButton.setTitle(LGLocalizedString.commonNo, forState: .Normal)
        
        switch family {
        case .iPhone4:
            titleLabel.font = StyleHelper.tourNotificationsTitleMiniFont
            subtitleLabel.font = StyleHelper.tourNotificationsSubtitleMiniFont
        case .iPhone5:
            titleLabel.font = StyleHelper.tourNotificationsTitleMiniFont
            subtitleLabel.font = StyleHelper.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = 165
        case .iPhone6, .iPhone6Plus:
            titleLabel.font = StyleHelper.tourNotificationsTitleFont
            subtitleLabel.font = StyleHelper.tourNotificationsSubtitleFont
        }
    }
}