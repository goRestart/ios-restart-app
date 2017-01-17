//
//  SocialShareView.swift
//  LetGo
//
//  Created by Eli Kohen on 15/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import FBSDKShareKit
import MessageUI
import RxSwift
import RxCocoa

enum SocialShareState {
    case completed
    case cancelled
    case failed
}

protocol SocialShareViewDelegate: class {
    func viewController() -> UIViewController?
}

enum SocialShareViewStyle {
    case line, grid
}


class SocialShareView: UIView {

    static let defaultShareTypes: [ShareType] = [.sms, .facebook, .twitter ,.fbMessenger, .whatsapp, .email, .copyLink]
    
    var buttonsSide: CGFloat = 56 {
        didSet {
            setAvailableButtons()
        }
    }

    var style = SocialShareViewStyle.line {
        didSet {
            setAvailableButtons()
        }
    }
    var gridColumns = 3 {
        didSet {
            setAvailableButtons()
        }
    }

    // buttons configuration vars
    var specificCountry: String?
    var maxButtons: Int?
    var mustShowMoreOptions: Bool?
    var useBigButtons: Bool = false

    weak var delegate: SocialShareViewDelegate?
    var socialMessage: SocialMessage?
    var shareTypes = SocialShareView.defaultShareTypes

    var socialSharer: SocialSharer?

    private let containerView = UIView()
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContainer()
        setAvailableButtons()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContainer()
        setAvailableButtons()
    }

    
    func setupWithShareTypes(_ shareTypes: [ShareType], useBigButtons: Bool) {
        self.shareTypes = shareTypes
        self.useBigButtons = useBigButtons
        setAvailableButtons()
    }

    // MARK: - Private methods

    private func setupContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal,
            toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal,
            toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .left, relatedBy: .equal,
            toItem: self, attribute: .left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .right, relatedBy: .equal,
            toItem: self, attribute: .right, multiplier: 1.0, constant: 0))
    }

    private func setAvailableButtons() {
        containerView.removeConstraints(constraints)
        containerView.subviews.forEach { $0.removeFromSuperview() }

        let buttons = buttonListForShareTypes(shareTypes)
        guard !buttons.isEmpty else { return }
        switch style {
        case .line:
            setupButtonsInLine(buttons, container: containerView)
        case .grid:
            buttons.count <= gridColumns + 1 ? setupButtonsInLine(buttons, container: containerView) :
            setupButtonsInGrid(buttons, container: containerView)
        }
    }

    private func buttonListForShareTypes(_ shareTypes: [ShareType]) -> [UIButton] {
        var buttons: [UIButton] = []
        for type in shareTypes {
            guard SocialSharer.canShareIn(type) else { continue }
            buttons.append(createButton(type))
        }
        return buttons
    }

    private func createButton(_ shareType: ShareType) -> UIButton {
        let image = useBigButtons ? shareType.bigImage : shareType.smallImage
        return createButton(image, accesibilityId: shareType.accesibilityId) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }

            strongSelf.socialSharer?.share(socialMessage, shareType: shareType, viewController: viewController)
        }
    }

    private func createButton(_ image: UIImage?, accesibilityId: AccessibilityId, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.accessibilityId = accessibilityId
        button.rx.tap.subscribeNext { _ in action() }.addDisposableTo(disposeBag)
        let width = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil,
                                    attribute: .notAnAttribute, multiplier: 1.0, constant: buttonsSide)
        let height = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil,
                                    attribute: .notAnAttribute, multiplier: 1.0, constant: buttonsSide)
        button.addConstraints([width, height])
        return button
    }

    private func setupButtonsInLine(_ buttons: [UIButton], container: UIView) {
        buttons.forEach { container.addSubview($0) }
        var previous: UIButton? = nil
        for (index, button) in buttons.enumerated() {
            if let previous = previous {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal,
                    toItem: previous, attribute: .right, multiplier: 1.0, constant: 0))
            } else {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal,
                    toItem: container, attribute: .left, multiplier: 1.0, constant: 0))
            }
            container.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal,
                toItem: container, attribute: .top, multiplier: 1.0, constant: 0))
            container.addConstraint(NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal,
                toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0))
            if index == buttons.count - 1 {
                let constraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .greaterThanOrEqual,
                                                    toItem: container, attribute: .right, multiplier: 1.0, constant: 0)
                constraint.priority = UILayoutPriorityDefaultHigh
                container.addConstraint(constraint)
            }
            previous = button
        }
    }

    private func setupButtonsInGrid(_ buttons: [UIButton], container: UIView) {
        buttons.forEach { container.addSubview($0) }
        let maxRow = floor(CGFloat(buttons.count-1) / CGFloat(gridColumns))
        var previous: UIButton? = nil
        var top: UIButton? = nil
        for (index, button) in buttons.enumerated() {
            if let previous = previous {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal,
                    toItem: previous, attribute: .right, multiplier: 1.0, constant: 0))
            } else {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal,
                    toItem: container, attribute: .left, multiplier: 1.0, constant: 0))
            }

            if let top = top {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal,
                    toItem: top, attribute: .bottom, multiplier: 1.0, constant: 0))
            } else {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal,
                    toItem: container, attribute: .top, multiplier: 1.0, constant: 0))
            }

            let currentRow = floor(CGFloat(index) / CGFloat(gridColumns))
            if currentRow == maxRow {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal,
                    toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0))
            }

            if index % gridColumns == gridColumns - 1 {
                let constraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .greaterThanOrEqual,
                                                    toItem: container, attribute: .right, multiplier: 1.0, constant: 0)
                constraint.priority = UILayoutPriorityDefaultHigh
                container.addConstraint(constraint)
                top = button
                previous = nil
            } else {
                previous = button
            }
        }
    }
}
