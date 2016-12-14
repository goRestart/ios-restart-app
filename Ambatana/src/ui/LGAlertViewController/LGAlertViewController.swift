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
    case IconAlert(icon: UIImage?)

    var titleTopSeparation: CGFloat {
        switch self {
        case .PlainAlert:
            return 20
        case let .IconAlert(icon):
            return icon == nil ? 20 : 75
        }
    }

    var contentTopSeparation: CGFloat {
        switch self {
        case .PlainAlert:
            return 0
        case let .IconAlert(icon):
            return icon == nil ? 0 : 55
        }
    }

    var containerCenterYOffset: CGFloat {
        return -contentTopSeparation/2
    }
}

class LGAlertViewController: UIViewController {

    static let buttonsMargin: CGFloat = 5
    static let buttonsHeight: CGFloat = 44
    static let buttonsContainerTopSeparation: CGFloat = 20

    @IBOutlet weak var alertIcon: UIImageView!
    @IBOutlet weak var alertContentView: UIView!
    @IBOutlet weak var alertTitleLabel: UILabel!
    @IBOutlet weak var alertTextLabel: UILabel!

    @IBOutlet weak var alertContainerCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertContentTopSeparationConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertTitleTopSeparationConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var buttonsContainerViewTopSeparationConstraint: NSLayoutConstraint!

    private let alertType: AlertType

    private let alertTitle: String?
    private let alertText: String?
    private let alertActions: [UIAction]?

    // Rx
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    init?(title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        self.alertTitle = title
        self.alertText = text
        self.alertActions = actions
        self.alertType = alertType
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
        
        switch alertType {
        case .PlainAlert:
            alertIcon.image = nil
        case let .IconAlert(icon):
            alertIcon.image = icon
        }

        alertContentTopSeparationConstraint.constant = alertType.contentTopSeparation
        alertTitleTopSeparationConstraint.constant = alertType.titleTopSeparation
        alertContainerCenterYConstraint.constant = alertType.containerCenterYOffset

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeWithFadeOut))
        view.addGestureRecognizer(tapRecognizer)

        alertContentView.layer.cornerRadius = LGUIKitConstants.alertCornerRadius

        alertTitleLabel.text = alertTitle
        alertTitleLabel.font = UIFont.systemMediumFont(size: 17)
        alertTextLabel.text = alertText
        alertTextLabel.font = UIFont.systemRegularFont(size: 15)
        
        setupButtons(alertActions)
    }

    private func setupButtons(actions: [UIAction]?) {

        buttonsContainer.subviews.forEach { $0.removeFromSuperview() }

        // Actions must have interface == .Button
        let buttonActions: [UIAction] = actions?.filter { $0.buttonStyle != nil } ?? []
        // No actions -> No buttons
        guard buttonActions.count > 0 else {
            buttonsContainerViewTopSeparationConstraint.constant = 0
            return
        }
        buttonsContainerViewTopSeparationConstraint.constant = LGAlertViewController.buttonsContainerTopSeparation

        let widthMultiplier: CGFloat = 1 / CGFloat(buttonActions.count)
        let widthConstant: CGFloat = buttonActions.count == 1 ? 0 : -(LGAlertViewController.buttonsMargin/2)
        var previous: UIView? = nil
        for action in buttonActions {
            let button = UIButton(type: .Custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonsContainer.addSubview(button)
            button.fitVerticallyToParent()
            button.setHeightConstraint(LGAlertViewController.buttonsHeight)
            button.setWidthConstraint(multiplier: widthMultiplier, constant: widthConstant)
            if let previous = previous {
                button.toRightOf(previous, margin: LGAlertViewController.buttonsMargin)
            } else {
                button.alignParentLeft()
            }
            bindButtonWithAction(button, action: action)
            previous = button
        }
        if let lastBtn = previous {
            lastBtn.alignParentRight()
        }
    }

    private func bindButtonWithAction(button: UIButton, action: UIAction) {
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .Center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitle(action.text, forState: .Normal)
        button.accessibilityId = action.accessibilityId
        button.setStyle(action.buttonStyle ?? .Primary(fontSize: .Medium))
        button.rx_tap.bindNext { [weak self] _ in
            self?.closeWithFadeOutWithCompletion {
                action.action()
            }
        }.addDisposableTo(disposeBag)
    }

    dynamic private func closeWithFadeOut() {
        closeWithFadeOutWithCompletion(nil)
    }

    private func closeWithFadeOutWithCompletion(completion: (() -> Void)?) {
        dismissViewControllerAnimated(true, completion: completion)
    }
}
