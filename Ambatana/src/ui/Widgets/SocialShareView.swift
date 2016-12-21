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
    case Completed
    case Cancelled
    case Failed
}

protocol SocialShareViewDelegate: class {
    func viewController() -> UIViewController?
}

enum SocialShareViewStyle {
    case Line, Grid
}


class SocialShareView: UIView {

    static let defaultShareTypes: [ShareType] = [.SMS, .Facebook, .Twitter ,.FBMessenger, .Whatsapp, .Email, .CopyLink]
    
    var buttonsSide: CGFloat = 56 {
        didSet {
            setAvailableButtons()
        }
    }

    var style = SocialShareViewStyle.Line {
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

    
    func setupWithShareTypes(shareTypes: [ShareType], useBigButtons: Bool) {
        self.shareTypes = shareTypes
        self.useBigButtons = useBigButtons
        setAvailableButtons()
    }

    // MARK: - Private methods

    private func setupContainer() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .Top, relatedBy: .Equal,
            toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal,
            toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .Left, relatedBy: .Equal,
            toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .Right, relatedBy: .Equal,
            toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
    }

    private func setAvailableButtons() {
        containerView.removeConstraints(constraints)
        containerView.subviews.forEach { $0.removeFromSuperview() }

        let buttons = buttonListForShareTypes(shareTypes)
        guard !buttons.isEmpty else { return }
        switch style {
        case .Line:
            setupButtonsInLine(buttons, container: containerView)
        case .Grid:
            buttons.count <= gridColumns + 1 ? setupButtonsInLine(buttons, container: containerView) :
            setupButtonsInGrid(buttons, container: containerView)
        }
    }

    private func buttonListForShareTypes(shareTypes: [ShareType]) -> [UIButton] {
        var buttons: [UIButton] = []
        for type in shareTypes {
            guard SocialSharer.canShareIn(type) else { continue }
            buttons.append(createButton(type))
        }
        return buttons
    }

    private func createButton(shareType: ShareType) -> UIButton {
        let image = useBigButtons ? shareType.bigImage : shareType.smallImage
        return createButton(image, accesibilityId: shareType.accesibilityId) { [weak self] in
            guard let strongSelf = self else { return }
            guard let socialMessage = strongSelf.socialMessage else { return }
            guard let viewController = strongSelf.delegate?.viewController() else { return }

            strongSelf.socialSharer?.share(socialMessage, shareType: shareType, viewController: viewController)
        }
    }

    private func createButton(image: UIImage?, accesibilityId: AccessibilityId, action: () -> Void) -> UIButton {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, forState: .Normal)
        button.accessibilityId = accessibilityId
        button.rx_tap.subscribeNext(action).addDisposableTo(disposeBag)
        let width = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil,
                                    attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsSide)
        let height = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                    attribute: .NotAnAttribute, multiplier: 1.0, constant: buttonsSide)
        button.addConstraints([width, height])
        return button
    }

    private func setupButtonsInLine(buttons: [UIButton], container: UIView) {
        buttons.forEach { container.addSubview($0) }
        var previous: UIButton? = nil
        for (index, button) in buttons.enumerate() {
            if let previous = previous {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal,
                    toItem: previous, attribute: .Right, multiplier: 1.0, constant: 0))
            } else {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal,
                    toItem: container, attribute: .Left, multiplier: 1.0, constant: 0))
            }
            container.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal,
                toItem: container, attribute: .Top, multiplier: 1.0, constant: 0))
            container.addConstraint(NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal,
                toItem: container, attribute: .Bottom, multiplier: 1.0, constant: 0))
            if index == buttons.count - 1 {
                let constraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .GreaterThanOrEqual,
                                                    toItem: container, attribute: .Right, multiplier: 1.0, constant: 0)
                constraint.priority = UILayoutPriorityDefaultHigh
                container.addConstraint(constraint)
            }
            previous = button
        }
    }

    private func setupButtonsInGrid(buttons: [UIButton], container: UIView) {
        buttons.forEach { container.addSubview($0) }
        let maxRow = floor(CGFloat(buttons.count-1) / CGFloat(gridColumns))
        var previous: UIButton? = nil
        var top: UIButton? = nil
        for (index, button) in buttons.enumerate() {
            if let previous = previous {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal,
                    toItem: previous, attribute: .Right, multiplier: 1.0, constant: 0))
            } else {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal,
                    toItem: container, attribute: .Left, multiplier: 1.0, constant: 0))
            }

            if let top = top {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal,
                    toItem: top, attribute: .Bottom, multiplier: 1.0, constant: 0))
            } else {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal,
                    toItem: container, attribute: .Top, multiplier: 1.0, constant: 0))
            }

            let currentRow = floor(CGFloat(index) / CGFloat(gridColumns))
            if currentRow == maxRow {
                container.addConstraint(NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal,
                    toItem: container, attribute: .Bottom, multiplier: 1.0, constant: 0))
            }

            if index % gridColumns == gridColumns - 1 {
                let constraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .GreaterThanOrEqual,
                                                    toItem: container, attribute: .Right, multiplier: 1.0, constant: 0)
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
