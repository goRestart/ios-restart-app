//
//  TourLocationViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 5/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class TourLocationViewController: BaseViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iphoneRightHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let viewModel: TourLocationViewModel
    
    var completion: (() -> ())?
    
    
    // MARK: - Lifecycle

    init(viewModel: TourLocationViewModel) {
        self.viewModel = viewModel
        switch DeviceFamily.current {
        case .iPhone4:
            super.init(viewModel: nil, nibName: "TourLocationViewControllerMini",
                       statusBarStyle: UIApplication.sharedApplication().statusBarStyle)
        case .iPhone5, .iPhone6, .iPhone6Plus, .unknown:
            super.init(viewModel: nil, nibName: "TourLocationViewController",
                       statusBarStyle: UIApplication.sharedApplication().statusBarStyle)
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
        setStatusBarHidden(true)
        viewModel.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didAskNativeLocationPermission),
            name: LocationManager.Notification.LocationDidChangeAuthorization.rawValue, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        setStatusBarHidden(false)
    }

    func didAskNativeLocationPermission() {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) { [weak self] in
            self?.openNextStep()
        }
    }

    func close() {
        viewModel.userDidTapNoButton()
        openNextStep()
    }

    func openNextStep() {
        guard let step = viewModel.nextStep() else { return }
        switch step {
        case .Posting:
            showTourPosting()
        case .None:
            dismissViewControllerAnimated(true, completion: completion)
        }
    }

    
    // MARK: - IBActions
    
    @IBAction func yesButtonPressed(sender: AnyObject) {
        viewModel.userDidTapYesButton()
        Core.locationManager.startSensorLocationUpdates()
    }
    
    @IBAction func noButtonPressed(sender: AnyObject) {
        close()
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        close()
    }
    
    
    // MARK: - Private
    
    private func setupUI() {
        titleLabel.text = LGLocalizedString.locationPermissionsTitle
        subtitleLabel.text = LGLocalizedString.locationPermissonsSubtitle
        distanceLabel.text = LGLocalizedString.locationPermissionsBubble
        
        yesButton.tintColor = UIColor.whiteColor()
        yesButton.titleLabel?.font = UIFont.tourButtonFont
        yesButton.setTitle(LGLocalizedString.locationPermissionsButton, forState: .Normal)
        yesButton.setStyle(.Primary(fontSize: .Medium))
        yesButton.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        
        noButton.backgroundColor = UIColor.clearColor()
        noButton.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        noButton.layer.borderWidth = 1
        noButton.layer.borderColor = UIColor.whiteColor().CGColor
        noButton.tintColor = UIColor.whiteColor()
        noButton.titleLabel?.font = UIFont.tourButtonFont
        noButton.setTitle(LGLocalizedString.commonNo, forState: .Normal)
        
        labelContainer.layer.cornerRadius = labelContainer.height/2
        distanceLabel.font = UIFont.tourLocationDistanceLabelFont
        distanceLabel.textColor = UIColor.black
        
        switch DeviceFamily.current {
        case .iPhone4:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
        case .iPhone5:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = 165
        case .iPhone6, .iPhone6Plus, .unknown:
            titleLabel.font = UIFont.tourNotificationsTitleFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleFont
        }
    }

    func showTourPosting() {
        let vm = TourPostingViewModel()
        let vc = TourPostingViewController(viewModel: vm) { [weak self] in
            self?.dismissViewControllerAnimated(false, completion: self?.completion)
        }
        UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.alpha = 0
            }, completion: nil)

        presentViewController(vc, animated: true, completion: nil)
    }

    private func setupAccessibilityIds() {
        closeButton.accessibilityId = .TourLocationCloseButton
        yesButton.accessibilityId = .TourLocationOKButton
        noButton.accessibilityId = .TourLocationCancelButton
    }
}