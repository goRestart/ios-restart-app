//
//  ExpandableButtonsView.swift
//  LetGo
//
//  Created by Albert Hernández López on 25/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class ExpandableButtonsView: UIView {
    private var buttons: [UIButton] = []
    private var actions: [() -> ()] = []

    private let buttonSide: CGFloat
    private let buttonSpacing: CGFloat
    let expanded = Variable<Bool>(false)

    private var topConstraints: [NSLayoutConstraint] = []
    private let disposeBag: DisposeBag = DisposeBag()


    // MARK: - Lifecycle

    init(buttonSide: CGFloat, buttonSpacing: CGFloat) {
        self.buttonSide = buttonSide
        self.buttonSpacing = buttonSpacing
        super.init(frame: CGRect.zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Public methods

extension ExpandableButtonsView {
    func addButton(image image: UIImage?, bgColor: UIColor?, accessibilityId: AccessibilityId?, action: () -> ()) {
        guard !expanded.value else { return }

        let actionIdx = actions.count
        actions.append(action)

        let button = UIButton(type: .Custom)
        button.tag = actionIdx
        button.setImage(image, forState: .Normal)
        button.setBackgroundImage(bgColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        button.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
        button.accessibilityId = accessibilityId
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)

        buttons.append(button)

        let top = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal,
                                     toItem: self, attribute: .Top,
                                     multiplier: 1, constant: marginForButtonAtIndex(actionIdx, expanded: expanded.value))
        topConstraints.append(top)
        let bottom = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .LessThanOrEqual,
                                        toItem: self, attribute: .Bottom,
                                        multiplier: 1, constant: -buttonSpacing)
        let left = NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal,
                                        toItem: self, attribute: .Leading,
                                        multiplier: 1, constant: buttonSpacing)
        let right = NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal,
                                       toItem: self, attribute: .Trailing,
                                       multiplier: 1, constant: -buttonSpacing)
        let width = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal,
                                       toItem: nil, attribute: .NotAnAttribute,
                                       multiplier: 1, constant: buttonSide)
        let height = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal,
                                        toItem: nil, attribute: .NotAnAttribute,
                                        multiplier: 1, constant: buttonSide)
        addConstraints([top, bottom, left, right, width, height])
    }

    func expand(animated animated: Bool) {
        updateExpanded(true, animated: animated)
    }

    func shrink(animated animated: Bool) {
        updateExpanded(false, animated: animated)
    }

    func switchExpanded(animated animated: Bool) {
        if expanded.value {
            shrink(animated: animated)
        } else {
            expand(animated: animated)
        }
    }
}


// MARK: - Private methods

private extension ExpandableButtonsView {
    func setupUI() {
        alpha = 0
        clipsToBounds = true
        layer.cornerRadius = (buttonSide + buttonSpacing * 2) / 2
        backgroundColor = UIColor.white.colorWithAlphaComponent(0.3)
    }

    private func updateExpanded(expanded: Bool, animated: Bool) {
        self.expanded.value = expanded

        (0..<buttons.count).forEach {
            let idx = $0
            let margin = marginForButtonAtIndex(idx, expanded: expanded)
            topConstraints[idx].constant = margin
        }

        let animations = { [weak self] in
            self?.alpha = expanded ? 1.0 : 0.0
            self?.superview?.layoutIfNeeded()
        }
        if animated {
            if expanded {
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5,
                                           options: [], animations: animations, completion: nil)
            } else {
                UIView.animateWithDuration(0.25, animations: animations, completion: nil)
                UIView.animateWithDuration(0.25, animations: animations)
            }
        } else {
            animations()
        }
    }

    func marginForButtonAtIndex(index: Int, expanded: Bool) -> CGFloat {
        return expanded ? (buttonSpacing + (buttonSpacing + buttonSide) * CGFloat(index)) : buttonSpacing
    }

    dynamic func buttonPressed(button: UIButton) {
        let actionIdx = button.tag
        guard 0..<actions.count ~= actionIdx else { return }

        actions[actionIdx]()
    }
}
