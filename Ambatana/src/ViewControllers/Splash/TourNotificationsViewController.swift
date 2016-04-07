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
            super.init(viewModel: viewModel, nibName: "TourNotificationsViewControllerMini",
                       statusBarStyle: .LightContent)
        case .iPhone5, .iPhone6, .iPhone6Plus, .unknown:
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
        setupTexts()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(TourNotificationsViewController.didRegisterUserNotificationSettings),
            name: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue, object: nil)
        viewModel.viewDidLoad()
    }

    func didRegisterUserNotificationSettings() {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) { [weak self] in
            self?.openNextStep()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }

    
    // MARK: - Navigation
    
    func openNextStep() {
        switch viewModel.nextStep() {
        case .Location:
            showTourLocation()
        case .None:
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
        PushPermissionsManager.sharedInstance.showPushPermissionsAlertFromViewController(self, prePermissionType: .Onboarding)
    }
    
    func showTourLocation() {
        let vm = TourLocationViewModel(source: .Install)
        let vc = TourLocationViewController(viewModel: vm)
        vc.completion = { [weak self] in
            self?.dismissViewControllerAnimated(false, completion: self?.completion)
        }
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
        
        noButton.setTitle(LGLocalizedString.commonNo, forState: .Normal)
        notifyButton.setTitle(LGLocalizedString.notificationsPermissionsYesButton, forState: .Normal)
        notificationTimeLabel.text = LGLocalizedString.commonTimeNowLabel
    }
    
    func setupUI() {
        notifyButton.tintColor = UIColor.whiteColor()
        notifyButton.titleLabel?.font = StyleHelper.tourButtonFont
        notifyButton.setPrimaryStyle()
        notifyButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        
        noButton.backgroundColor = UIColor.clearColor()
        noButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        noButton.layer.borderWidth = 1
        noButton.layer.borderColor = UIColor.whiteColor().CGColor
        noButton.tintColor = UIColor.whiteColor()
        noButton.titleLabel?.font = StyleHelper.tourButtonFont
        
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