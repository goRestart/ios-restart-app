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
    case plainAlert
    case iconAlert(icon: UIImage?)

    var titleTopSeparation: CGFloat {
        switch self {
        case .plainAlert:
            return 20
        case let .iconAlert(icon):
            return icon == nil ? 20 : 75
        }
    }

    var contentTopSeparation: CGFloat {
        switch self {
        case .plainAlert:
            return 0
        case let .iconAlert(icon):
            return icon == nil ? 0 : 55
        }
    }

    var containerCenterYOffset: CGFloat {
        return -contentTopSeparation/2
    }
}

enum AlertButtonsLayout {
    case horizontal, vertical
}

class LGAlertViewController: UIViewController {

    static let buttonsMargin: CGFloat = 5
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
    private let buttonsLayout: AlertButtonsLayout

    private let alertTitle: String?
    private let alertText: String?
    private let alertActions: [UIAction]?

    // Rx
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    init?(title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout = .horizontal, actions: [UIAction]?) {
        self.alertTitle = title
        self.alertText = text
        self.alertActions = actions
        self.alertType = alertType
        self.buttonsLayout = buttonsLayout
        super.init(nibName: "LGAlertViewController", bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
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
        case .plainAlert:
            alertIcon.image = nil
        case let .iconAlert(icon):
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

    private func setupButtons(_ actions: [UIAction]?) {

        buttonsContainer.subviews.forEach { $0.removeFromSuperview() }

        // Actions must have interface == .button
        let buttonActions: [UIAction] = actions?.filter { $0.buttonStyle != nil } ?? []
        // No actions -> No buttons
        guard buttonActions.count > 0 else {
            buttonsContainerViewTopSeparationConstraint.constant = 0
            return
        }
        buttonsContainerViewTopSeparationConstraint.constant = LGAlertViewController.buttonsContainerTopSeparation

        switch buttonsLayout {
        case .horizontal:
            buildButtonsHorizontally(buttonActions)
        case .vertical:
            buildButtonsVertically(buttonActions)
        }
    }

    private func buildButtonsHorizontally(_ buttonActions: [UIAction]) {
        let widthMultiplier: CGFloat = 1 / CGFloat(buttonActions.count)
        let widthConstant: CGFloat = buttonActions.count == 1 ? 0 : -(LGAlertViewController.buttonsMargin/2)
        var previous: UIView? = nil
        for action in buttonActions {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonsContainer.addSubview(button)
            button.layout(with: buttonsContainer).fillVertical().width(widthConstant, multiplier: widthMultiplier)
            button.layout().height(LGUIKitConstants.mediumButtonHeight)
            if let previous = previous {
                button.layout(with: previous).left(to: .right, by: LGAlertViewController.buttonsMargin)
            } else {
                button.layout(with: buttonsContainer).left()
            }
            bindButtonWithAction(button, action: action)
            previous = button
        }
        if let lastBtn = previous {
            lastBtn.layout(with: buttonsContainer).right()
        }
    }

    private func buildButtonsVertically(_ buttonActions: [UIAction]) {
        var previous: UIView? = nil
        for action in buttonActions {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonsContainer.addSubview(button)
            button.layout(with: buttonsContainer).fillHorizontal()
            button.layout().height(LGUIKitConstants.mediumButtonHeight)
            if let previous = previous {
                button.layout(with: previous).top(to: .bottom, by: LGAlertViewController.buttonsMargin)
            } else {
                button.layout(with: buttonsContainer).top()
            }
            bindButtonWithAction(button, action: action)
            previous = button
        }
        if let lastBtn = previous {
            lastBtn.layout(with: buttonsContainer).bottom()
        }
    }

    private func bindButtonWithAction(_ button: UIButton, action: UIAction) {
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitle(action.text, for: .normal)
        button.accessibilityId = action.accessibilityId
        button.setStyle(action.buttonStyle ?? .primary(fontSize: .medium))
        button.rx.tap.bindNext { [weak self] _ in
            self?.closeWithFadeOutWithCompletion {
                action.action()
            }
        }.addDisposableTo(disposeBag)
    }

    dynamic private func closeWithFadeOut() {
        closeWithFadeOutWithCompletion(nil)
    }

    private func closeWithFadeOutWithCompletion(_ completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }
}
