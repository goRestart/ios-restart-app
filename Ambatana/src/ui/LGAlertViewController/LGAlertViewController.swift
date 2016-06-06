//
//  LGAlertViewController.swift
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

class LGAlertViewController: UIViewController {

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

    private var alertTitle: String?
    private var alertText: String?
    private var alertIconName: String?
    private var alertActions: [UIAction]?

    // Rx
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    init?(title: String, text: String, iconName: String?, actions: [UIAction]?) {
        self.alertTitle = title
        self.alertText = text
        self.alertIconName = iconName
        self.alertActions = actions
        super.init(nibName: "LGAlertViewController", bundle: nil)
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


    // MARK: - Private Methods

    private func setupUI() {
        view.alpha = 0

        if let actualIconName = alertIconName, let image = UIImage(named: actualIconName) {
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
        view.addGestureRecognizer(tapRecognizer)

        alertContentView.layer.cornerRadius = StyleHelper.alertCornerRadius

        alertTitleLabel.text = alertTitle
        alertTitleLabel.font = UIFont.systemMediumFont(size: 17)
        alertTextLabel.text = alertText
        alertTextLabel.font = UIFont.systemRegularFont(size: 15)
        
        setupButtons(alertActions)
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
            buttonsContainerViewHeightConstraint.constant = LGAlertViewController.buttonsContainerMaxHeight
            buttonsContainerViewTopSeparationConstraint.constant = LGAlertViewController.buttonsContainerTopSeparation
            buttonSeparationConstraint.constant = 0
            secondaryButtonWidthConstraint.constant = 0
            bindButtonWithAction(alertMainButton, action: buttonActions[0])
        default:
            // 2 or more actions, we ignore from the third and beyond
            buttonsContainerViewHeightConstraint.constant = LGAlertViewController.buttonsContainerMaxHeight
            buttonsContainerViewTopSeparationConstraint.constant = LGAlertViewController.buttonsContainerTopSeparation
            buttonSeparationConstraint.constant = LGAlertViewController.buttonsSeparation
            secondaryButtonWidthConstraint.constant = LGAlertViewController.buttonMaxWidth
            bindButtonWithAction(alertMainButton, action: buttonActions[0])
            bindButtonWithAction(alertSecondaryButton, action: buttonActions[1])
        }

        alertMainButton.layer.cornerRadius = StyleHelper.alertButtonCornerRadius
        alertSecondaryButton.layer.cornerRadius = StyleHelper.alertButtonCornerRadius
    }

    private func bindButtonWithAction(button: UIButton, action: UIAction) {
        button.setTitle(action.text, forState: .Normal)
        button.setStyle(action.buttonStyle ?? .Primary(fontSize: .Medium))
        button.rx_tap.bindNext { [weak self] _ in
            action.action()
            self?.closeWithFadeOut()
        }.addDisposableTo(disposeBag)
    }

    dynamic private func closeWithFadeOut() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
