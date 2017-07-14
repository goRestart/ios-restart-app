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
    case plainAlertOld
    case iconAlert(icon: UIImage?)

    var titleTopSeparation: CGFloat {
        switch self {
        case .plainAlertOld, .plainAlert:
            return 20
        case let .iconAlert(icon):
            return icon == nil ? 20 : 75
        }
    }

    var contentTopSeparation: CGFloat {
        switch self {
        case .plainAlertOld, .plainAlert:
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
    case horizontal
    case vertical
    case emojis
    
    var buttonsHeight: CGFloat {
        switch self {
        case .horizontal, .vertical:
            return LGUIKitConstants.mediumButtonHeight
        case .emojis:
            return 60
        }
    }
    
    var buttonsMargin: CGFloat {
        switch self {
        case .horizontal, .vertical:
            return 10
        case .emojis:
            return 50
        }
    }
    
    var topButtonMargin: CGFloat {
        switch self {
        case .horizontal:
            return 0
        case .emojis, .vertical:
            return 25
        }
    }
}

class LGAlertViewController: UIViewController {

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
    private let dismissAction: (() -> ())?

    private let disposeBag = DisposeBag()
    
    var simulatePushTransitionOnPresent: Bool = false
    var simulatePushTransitionOnDismiss: Bool = false

    // MARK: - Lifecycle

    init?(title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout = .horizontal,
          actions: [UIAction]?, dismissAction: (() -> ())? = nil) {
        self.alertTitle = title
        self.alertText = text
        self.alertActions = actions
        self.alertType = alertType
        self.buttonsLayout = buttonsLayout
        self.dismissAction = dismissAction
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if simulatePushTransitionOnPresent {
            let animation = CATransition()
            animation.type = kCATransitionPush
            animation.subtype = kCATransitionFromRight
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            alertContentView.layer.add(animation, forKey: kCATransition)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if simulatePushTransitionOnDismiss {
            let animation = CATransition()
            animation.type = kCATransitionPush
            animation.subtype = kCATransitionFromRight
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.alertContentView.layer.add(animation, forKey: kCATransition)
            self.alertContentView.alpha = 0
        }
    }


    // MARK: - Private Methods

    private func setupUI() {
        
        switch alertType {
        case .plainAlert:
            alertIcon.image = nil
            alertTitleLabel.font = UIFont.systemBoldFont(size: 23)
            alertTitleLabel.textAlignment = .left
        case .plainAlertOld:
            alertIcon.image = nil
            alertTitleLabel.font = UIFont.systemMediumFont(size: 17)
        case let .iconAlert(icon):
            alertIcon.image = icon
            alertTitleLabel.font = UIFont.systemMediumFont(size: 17)
        }
        alertTextLabel.font = UIFont.systemRegularFont(size: 15)
        alertTitleLabel.text = alertTitle
        alertTextLabel.text = alertText

        alertContentTopSeparationConstraint.constant = alertType.contentTopSeparation
        alertTitleTopSeparationConstraint.constant = alertType.titleTopSeparation
        alertContainerCenterYConstraint.constant = alertType.containerCenterYOffset

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOutside))
        view.addGestureRecognizer(tapRecognizer)

        alertContentView.layer.cornerRadius = LGUIKitConstants.alertCornerRadius
        
        setupButtons(alertActions)
    }

    private func setupButtons(_ actions: [UIAction]?) {

        buttonsContainer.subviews.forEach { $0.removeFromSuperview() }

        // Actions must have interface == .button
        guard let buttonActions = actions else { return }
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
        case .emojis:
            buildEmojiButtons(actions: buttonActions)
        }
    }

    private func buildEmojiButtons(actions: [UIAction]) {
        
        let centeredContainer = UIView()
        centeredContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.addSubview(centeredContainer)
        centeredContainer.layout(with: buttonsContainer)
            .top()
            .bottom()
            .centerX()
        var previous: UIView? = nil
        for action in actions {
            let button = UIButton(type: .custom)
            button.imageView?.contentMode = .scaleAspectFit
            button.translatesAutoresizingMaskIntoConstraints = false
            centeredContainer.addSubview(button)
            button.layout(with: centeredContainer)
                .top(by: AlertButtonsLayout.emojis.topButtonMargin)
                .bottom()
            button.layout()
                .width(AlertButtonsLayout.emojis.buttonsHeight)
                .widthProportionalToHeight()
            if let previous = previous {
                button.layout(with: previous)
                    .left(to: .right, by: AlertButtonsLayout.emojis.buttonsMargin)
            } else {
                button.layout(with: centeredContainer)
                    .left()
            }
            previous = button
            styleButton(button, action: action)
        }
        if let lastBtn = previous {
            lastBtn.layout(with: centeredContainer).right()
        }
        _ = buttonsContainer.addTopBorderWithWidth(1, color: UIColor.gray)
    }
    
    private func buildButtonsHorizontally(_ buttonActions: [UIAction]) {
        let widthMultiplier: CGFloat = 1 / CGFloat(buttonActions.count)
        let widthConstant: CGFloat = buttonActions.count == 1 ? 0 : -(AlertButtonsLayout.horizontal.buttonsMargin/2)
        var previous: UIView? = nil
        for action in buttonActions {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonsContainer.addSubview(button)
            button.layout(with: buttonsContainer)
                .top(by: AlertButtonsLayout.horizontal.topButtonMargin)
                .bottom()
                .width(widthConstant, multiplier: widthMultiplier)
            button.layout().height(AlertButtonsLayout.horizontal.buttonsHeight)
            if let previous = previous {
                button.layout(with: previous).left(to: .right, by: AlertButtonsLayout.horizontal.buttonsMargin)
            } else {
                button.layout(with: buttonsContainer).left()
            }
            previous = button
            styleButton(button, action: action)
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
            button.layout().height(AlertButtonsLayout.vertical.buttonsHeight)
            if let previous = previous {
                button.layout(with: previous).top(to: .bottom, by: AlertButtonsLayout.vertical.buttonsMargin)
            } else {
                button.layout(with: buttonsContainer).top(by: AlertButtonsLayout.vertical.topButtonMargin)
            }
            previous = button
            styleButton(button, action: action)
        }
        if let lastBtn = previous {
            lastBtn.layout(with: buttonsContainer).bottom()
        }
        _ = buttonsContainer.addTopBorderWithWidth(1, color: UIColor.gray)
    }

    private func styleButton(_ button: UIButton, action: UIAction) {
        switch action.interface {
        case let .image(image, _):
            button.setImage(image, for: .normal)
        case .button, .styledText, .text, .textImage:
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.setTitle(action.text, for: .normal)
            button.accessibilityId = action.accessibilityId
            button.setStyle(action.buttonStyle ?? .primary(fontSize: .medium))
        }
        
        button.rx.tap.bindNext { [weak self] _ in
            self?.closeWithFadeOutWithCompletion {
                action.action()
            }
        }.addDisposableTo(disposeBag)
    }

    dynamic private func tapOutside() {
        closeWithFadeOutWithCompletion { [weak self] in
            self?.dismissAction?()
        }
    }

    private func closeWithFadeOutWithCompletion(_ completion: (() -> Void)?) {
//        if simulatePushTransitionOnDismiss {
//            UIView.animate(withDuration: 0.2, animations: {
//                let animation = CATransition()
//                animation.type = kCATransitionPush
//                animation.subtype = kCATransitionFromRight
//                animation.duration = 0.2
//                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                self.alertContentView.layer.add(animation, forKey: kCATransition)
//            }, completion: { (completed) in
//                self.dismiss(animated: false, completion: completion)
//            })
//        } else {
            dismiss(animated: true, completion: completion)
//        }
    }
}
