//
//  TourLocationViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 5/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


final class TourLocationViewController: BaseViewController {
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iphoneRightHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var completion: (() -> ())?
    
    // MARK: - Lifecycle

    init() {
        switch DeviceFamily.current {
        case .iPhone4:
            super.init(viewModel: nil, nibName: "TourLocationViewControllerMini")
        case .iPhone5, .iPhone6, .iPhone6Plus, .unknown:
            super.init(viewModel: nil, nibName: "TourLocationViewController")
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
    
    @IBAction func yesButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: completion)
    }
    
    @IBAction func noButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: completion)
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: completion)
    }
    
    
    // MARK: - UI
    
    func setupUI() {
        yesButton.backgroundColor = StyleHelper.primaryColor
        yesButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        yesButton.tintColor = UIColor.whiteColor()
        yesButton.titleLabel?.font = StyleHelper.tourButtonFont
        
        noButton.backgroundColor = UIColor.clearColor()
        noButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        noButton.layer.borderWidth = 1
        noButton.layer.borderColor = UIColor.whiteColor().CGColor
        noButton.tintColor = UIColor.whiteColor()
        noButton.titleLabel?.font = StyleHelper.tourButtonFont
        noButton.setTitle(LGLocalizedString.commonNo, forState: .Normal)
        
        labelContainer.layer.cornerRadius = labelContainer.height/2
        distanceLabel.font = StyleHelper.tourLocationDistanceLabelFont
        distanceLabel.textColor = StyleHelper.tourLocationDistanceLabelColor
        
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