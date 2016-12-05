//
//  TourNotificationsViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class TourNotificationsViewController: BaseViewController {

    private static let iphone5InfoHeight: CGFloat = 210
    private static let iphone4InfoHeight: CGFloat = 200

    let viewModel: TourNotificationsViewModel

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var notifyButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iphoneRightHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iphoneBckgImage: UIImageView!
    @IBOutlet weak var pushContainer: UIView!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var notificationMessageLabel: UILabel!
    @IBOutlet weak var alertContainer: UIView!
    @IBOutlet weak var alertOkLabel: UILabel!

    var completion: (() -> ())?
    var pushDialogWasShown = false
    

    // MARK: - Lifecycle
    
    init(viewModel: TourNotificationsViewModel) {
        self.viewModel = viewModel
        
        switch DeviceFamily.current {
        case .iPhone4:
            super.init(viewModel: viewModel, nibName: "TourNotificationsViewControllerMini",
                       statusBarStyle: .LightContent)
        case .iPhone5, .iPhone6, .iPhone6Plus, .BiggerUnknown:
            super.init(viewModel: viewModel, nibName: "TourNotificationsViewController", statusBarStyle: .LightContent)
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
        setupAccessibilityIds()
        setupTexts()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(TourNotificationsViewController.didRegisterUserNotificationSettings),
            name: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(didBecomeActive),
                                                         name: UIApplicationDidBecomeActiveNotification, object: nil)
        viewModel.viewDidLoad()
    }

    func didRegisterUserNotificationSettings() {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) { [weak self] in
            guard let viewAlpha = self?.view.alpha where viewAlpha > 0 else { return }
            self?.openNextStep()
        }
    }
    
    
    func didBecomeActive() {
        guard pushDialogWasShown else { return }
        openNextStep()
    }
    
        
    // MARK: - Navigation
    
    func openNextStep() {
        guard let step = viewModel.nextStep() else { return }
        switch step {
        case .Location:
            showTourLocation()
        case .NoStep:
            dismissViewControllerAnimated(true, completion: completion)
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        noButtonPressed(sender)
    }
   
    @IBAction func noButtonPressed(sender: AnyObject) {
        viewModel.userDidTapNoButton()
        openNextStep()
    }
    
    @IBAction func yesButtonPressed(sender: AnyObject) {
        viewModel.userDidTapYesButton()
        PushPermissionsManager.sharedInstance.showPushPermissionsAlert(prePermissionType: .Onboarding)
        pushDialogWasShown = true
    }
    
    func showTourLocation() {
        let vm = TourLocationViewModel(source: .Install)
        let vc = TourLocationViewController(viewModel: vm)
        UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.alpha = 0
        }, completion: nil)
        
        presentViewController(vc, animated: true, completion: nil)
    }
    
    
    // MARK: - UI
    
    func setupTexts() {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        notificationMessageLabel.text = viewModel.pushText
        
        notifyButton.setTitle(LGLocalizedString.notificationsPermissionsYesButton, forState: .Normal)
        notificationTimeLabel.text = LGLocalizedString.commonTimeNowLabel

        alertOkLabel.text = LGLocalizedString.commonOk
    }
    
    func setupUI() {
        iphoneBckgImage.image = viewModel.infoImage
        notifyButton.setStyle(.Primary(fontSize: .Medium))

        switch DeviceFamily.current {
        case .iPhone4:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = TourNotificationsViewController.iphone4InfoHeight
        case .iPhone5:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = TourNotificationsViewController.iphone5InfoHeight
        case .iPhone6, .iPhone6Plus, .BiggerUnknown:
            titleLabel.font = UIFont.tourNotificationsTitleFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleFont
        }

        pushContainer.hidden = !viewModel.showPushInfo
        alertContainer.hidden = !viewModel.showAlertInfo
        let tap = UITapGestureRecognizer(target: self, action: #selector(yesButtonPressed(_:)))
        alertContainer.addGestureRecognizer(tap)
    }

    func setupAccessibilityIds() {
        closeButton.accessibilityId = .TourNotificationsCloseButton
        notifyButton.accessibilityId = .TourNotificationsOKButton
        alertContainer.accessibilityId = .TourNotificationsAlert
    }
}
