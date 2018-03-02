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
    private static let iphone5InfoHeight: CGFloat = 210
    private static let iphone4InfoHeight: CGFloat = 200

    let viewModel: TourLocationViewModel

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iphoneRightHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iphoneBckgImage: UIImageView!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var alertContainer: UIView!
    @IBOutlet weak var alertOkLabel: UILabel!

    
    // MARK: - Lifecycle

    init(viewModel: TourLocationViewModel) {
        self.viewModel = viewModel
        switch DeviceFamily.current {
        case .iPhone4:
            super.init(viewModel: nil, nibName: "TourLocationViewControllerMini",
                       statusBarStyle: .lightContent)
        case .iPhone5, .iPhone6, .iPhone6Plus, .biggerUnknown:
            super.init(viewModel: nil, nibName: "TourLocationViewController",
                       statusBarStyle: .lightContent)
        }

        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibilityIds()
        viewModel.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        labelContainer.setRoundedCorners()
    }

    func close() {
        viewModel.userDidTapNoButton()
    }

    
    // MARK: - IBActions
    
    @IBAction func yesButtonPressed(_ sender: AnyObject) {
        viewModel.userDidTapYesButton()
    }
    
    @IBAction func noButtonPressed(_ sender: AnyObject) {
        close()
    }

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        close()
    }
    
    
    // MARK: - Private
    
    private func setupUI() {
        view.backgroundColor = .clear
        titleLabel.text = viewModel.title
        subtitleLabel.text = LGLocalizedString.locationPermissonsSubtitle
        distanceLabel.text = LGLocalizedString.locationPermissionsBubble

        iphoneBckgImage.image = viewModel.infoImage
        yesButton.setTitle(LGLocalizedString.locationPermissionsButton, for: .normal)
        yesButton.setStyle(.primary(fontSize: .medium))

        distanceLabel.font = UIFont.tourLocationDistanceLabelFont
        distanceLabel.textColor = UIColor.lgBlack
        alertOkLabel.text = LGLocalizedString.locationPermissionsAllowButton
        
        switch DeviceFamily.current {
        case .iPhone4:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = TourLocationViewController.iphone4InfoHeight
        case .iPhone5:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = TourLocationViewController.iphone5InfoHeight
        case .iPhone6, .iPhone6Plus, .biggerUnknown:
            titleLabel.font = UIFont.tourNotificationsTitleFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleFont
        }

        labelContainer.isHidden = !viewModel.showBubbleInfo
        alertContainer.isHidden = !viewModel.showAlertInfo
        let tap = UITapGestureRecognizer(target: self, action: #selector(yesButtonPressed(_:)))
        alertContainer.addGestureRecognizer(tap)
    }

    private func setupAccessibilityIds() {
        closeButton.set(accessibilityId: .tourLocationCloseButton)
        yesButton.set(accessibilityId: .tourLocationOKButton)
        alertContainer.set(accessibilityId: .tourLocationAlert)
    }
}

// MARK: - TourLocationViewModelDelegate

extension TourLocationViewController: TourLocationViewModelDelegate {}
