//
//  TourNotificationsViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

final class TourNotificationsViewController: BaseViewController {
    let viewModel: TourNotificationsViewModel

    @IBOutlet weak var notifyButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iphoneRightHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var notificationMessageLabel: UILabel!
    
    var completion: (() -> ())?
    
    // MARK: - Lifecycle
    
    init(viewModel: TourNotificationsViewModel) {
        self.viewModel = viewModel
        
        switch DeviceFamily.current {
        case .iPhone4:
            super.init(viewModel: viewModel, nibName: "TourNotificationsViewControllerMini")
        case .iPhone5, .iPhone6, .iPhone6Plus, .unknown:
            super.init(viewModel: viewModel, nibName: "TourNotificationsViewController")
        }
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
        showTourLocation()
    }
    
    @IBAction func yesButtonPressed(sender: AnyObject) {
        PushPermissionsManager.sharedInstance.showPushPermissionsAlertFromViewController(self, prePermissionType: PrePermissionType.Onboarding)
        showTourLocation()
    }
    
    func showTourLocation() {
        let vc = TourLocationViewController()
        vc.completion = {
            self.dismissViewControllerAnimated(false, completion: self.completion)
        }
        UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.alpha = 0
        }, completion: nil)
        
        presentViewController(vc, animated: true, completion: nil)
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
        
        switch DeviceFamily.current {
        case .iPhone4:
            titleLabel.font = StyleHelper.tourNotificationsTitleMiniFont
            subtitleLabel.font = StyleHelper.tourNotificationsSubtitleMiniFont
        case .iPhone5:
            titleLabel.font = StyleHelper.tourNotificationsTitleMiniFont
            subtitleLabel.font = StyleHelper.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = 165
        case .iPhone6, .iPhone6Plus, .unknown:
            titleLabel.font = StyleHelper.tourNotificationsTitleFont
            subtitleLabel.font = StyleHelper.tourNotificationsSubtitleFont
        }
    }
}