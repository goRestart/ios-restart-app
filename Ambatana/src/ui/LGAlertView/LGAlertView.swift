//
//  LGAlertView.swift
//  LetGo
//
//  Created by Dídac on 02/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum AlertType {
    case PlainAlert
    case IconAlert

    var titleTopSeparation: CGFloat {
        switch self {
        case .PlainAlert:
            return 20
        case .IconAlert:
            return 75
        }
    }

    var contentTopSeparation: CGFloat {
        switch self {
        case .PlainAlert:
            return 0
        case .IconAlert:
            return 55
        }
    }

    var containerCenterYOffset: CGFloat {
        return -contentTopSeparation/2
    }
}

class LGAlertView: UIView {

    static let buttonMaxWidth: CGFloat = 110
    static let buttonsSeparation: CGFloat = 10
    static let buttonsContainerMaxHeight: CGFloat = 44
    static let buttonsContainerTopSeparation: CGFloat = 20

    @IBOutlet weak var alertIcon: UIImageView!
    @IBOutlet weak var alertContentView: UIView!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertTextLabel: UILabel!
    @IBOutlet weak var alertMainButton: UIButton!
    @IBOutlet weak var alertSecondaryButton: UIButton!

    @IBOutlet weak var alertContainerCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertContentTopSeparationConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertTitleTopSeparationConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondaryButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonSeparationConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsContainerViewTopSeparationConstraint: NSLayoutConstraint!

    var alertType: AlertType = .PlainAlert

    // Rx
    private let disposeBag = DisposeBag()


    static func alertView() -> LGAlertView? {
        guard let view = NSBundle.mainBundle().loadNibNamed("LGAlertView", owner: self, options: nil).first
            as? LGAlertView else { return nil }
        return view
    }

    func setupWithFrame(frame: CGRect, title: String, text: String, iconName: String?, actions: [UIAction]?) {
        self.alpha = 0
        self.showWithFadeIn()
        self.frame = frame

        if let actualIconName = iconName, let image = UIImage(named: actualIconName) {
            alertIcon.image = image
            alertType = .IconAlert
        } else {
            alertIcon.image = nil
            alertType = .PlainAlert
        }

        alertContentTopSeparationConstraint.constant = alertType.contentTopSeparation
        alertTitleTopSeparationConstraint.constant = alertType.titleTopSeparation
        alertContainerCenterYConstraint.constant = alertType.containerCenterYOffset

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeWithFadeOut))
        addGestureRecognizer(tapRecognizer)

        alertContentView.layer.cornerRadius = StyleHelper.alertCornerRadius

        alertTitleLabel.text = title
        alertTitleLabel.font = UIFont.systemMediumFont(size: 17)
        alertTextLabel.text = text
        alertTextLabel.font = UIFont.systemRegularFont(size: 15)

        setupButtons(actions)
    }

    private func setupButtons(actions: [UIAction]?) {

        // No actions -> No buttons
        guard let actions = actions else {
            buttonsContainerViewHeightConstraint.constant = 0
            buttonsContainerViewTopSeparationConstraint.constant = 0
            return
        }

        // Actions must have interface == .Button
        let buttonActions: [UIAction] = actions.filter { action -> Bool in
            switch action.interface {
            case .Button:
                return true
            case .Text, .StyledText, .TextImage, .Image:
                return false
            }
        }

        switch buttonActions.count {
        case 0:
            buttonsContainerViewHeightConstraint.constant = 0
            buttonsContainerViewTopSeparationConstraint.constant = 0
        case 1:
            buttonsContainerViewHeightConstraint.constant = LGAlertView.buttonsContainerMaxHeight
            buttonsContainerViewTopSeparationConstraint.constant = LGAlertView.buttonsContainerTopSeparation
            buttonSeparationConstraint.constant = 0
            secondaryButtonWidthConstraint.constant = 0
            bindButtonWithAction(alertMainButton, action: buttonActions[0])
        default:
            // 2 or more actions, we ignore from the third and beyond
            buttonsContainerViewHeightConstraint.constant = LGAlertView.buttonsContainerMaxHeight
            buttonsContainerViewTopSeparationConstraint.constant = LGAlertView.buttonsContainerTopSeparation
            buttonSeparationConstraint.constant = LGAlertView.buttonsSeparation
            secondaryButtonWidthConstraint.constant = LGAlertView.buttonMaxWidth
            bindButtonWithAction(alertMainButton, action: buttonActions[0])
            bindButtonWithAction(alertSecondaryButton, action: buttonActions[1])
        }

        alertMainButton.layer.cornerRadius = StyleHelper.alertButtonCornerRadius
        alertSecondaryButton.layer.cornerRadius = StyleHelper.alertButtonCornerRadius
    }


    // MARK: Private Methods

    private func bindButtonWithAction(button: UIButton, action: UIAction) {
        button.setTitle(action.text, forState: .Normal)
        button.setStyle(action.buttonStyle ?? .Primary(fontSize: .Medium))
        button.rx_tap.bindNext { [weak self] _ in
            action.action()
            self?.closeWithFadeOut()
        }.addDisposableTo(disposeBag)
    }

    private func showWithFadeIn() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 1
        })
    }

    dynamic private func closeWithFadeOut() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 0
        }) { (completed) -> Void in
            self.removeFromSuperview()
        }
    }
}
