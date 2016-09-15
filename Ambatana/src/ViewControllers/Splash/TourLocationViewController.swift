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
    @IBOutlet weak var noButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var noButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iphoneRightHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iphoneBckgImage: UIImageView!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var alertContainer: UIView!
    @IBOutlet weak var alertOkLabel: UILabel!

    private var iphone5InfoHeight: CGFloat {
        return viewModel.showNoButton ? 165 : 210
    }
    private var iphone4InfoHeight: CGFloat {
        return viewModel.showNoButton ? 156 : 200
    }

    let viewModel: TourLocationViewModel
    
    
    // MARK: - Lifecycle

    init(viewModel: TourLocationViewModel) {
        self.viewModel = viewModel
        switch DeviceFamily.current {
        case .iPhone4:
            super.init(viewModel: nil, nibName: "TourLocationViewControllerMini",
                       statusBarStyle: .LightContent)
        case .iPhone5, .iPhone6, .iPhone6Plus, .unknown:
            super.init(viewModel: nil, nibName: "TourLocationViewController",
                       statusBarStyle: .LightContent)
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
        viewModel.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didAskNativeLocationPermission),
            name: LocationManager.Notification.LocationDidChangeAuthorization.rawValue, object: nil)
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
        viewModel.nextStep()
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
        titleLabel.text = viewModel.title
        subtitleLabel.text = LGLocalizedString.locationPermissonsSubtitle
        distanceLabel.text = LGLocalizedString.locationPermissionsBubble

        iphoneBckgImage.image = viewModel.infoImage
        yesButton.setTitle(LGLocalizedString.locationPermissionsButton, forState: .Normal)
        yesButton.setStyle(.Primary(fontSize: .Medium))

        if viewModel.showNoButton {
            noButton.backgroundColor = UIColor.clearColor()
            noButton.layer.cornerRadius = noButton.height / 2
            noButton.layer.borderWidth = 1
            noButton.layer.borderColor = UIColor.whiteColor().CGColor
            noButton.tintColor = UIColor.whiteColor()
            noButton.titleLabel?.font = UIFont.tourButtonFont
            noButton.setTitle(LGLocalizedString.commonNo, forState: .Normal)
        } else {
            noButtonHeight.constant = 0
            noButtonTopConstraint.constant = 0
        }
        
        labelContainer.layer.cornerRadius = labelContainer.height/2
        distanceLabel.font = UIFont.tourLocationDistanceLabelFont
        distanceLabel.textColor = UIColor.black
        alertOkLabel.text = LGLocalizedString.locationPermissionsAllowButton
        
        switch DeviceFamily.current {
        case .iPhone4:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = iphone4InfoHeight
        case .iPhone5:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = iphone5InfoHeight
        case .iPhone6, .iPhone6Plus, .unknown:
            titleLabel.font = UIFont.tourNotificationsTitleFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleFont
        }

        labelContainer.hidden = !viewModel.showBubbleInfo
        alertContainer.hidden = !viewModel.showAlertInfo
        let tap = UITapGestureRecognizer(target: self, action: #selector(yesButtonPressed(_:)))
        alertContainer.addGestureRecognizer(tap)
    }

    private func setupAccessibilityIds() {
        closeButton.accessibilityId = .TourLocationCloseButton
        yesButton.accessibilityId = .TourLocationOKButton
        noButton.accessibilityId = .TourLocationCancelButton
        alertContainer.accessibilityId = .TourLocationAlert
    }
}
