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
    func addButton(image: UIImage?, accessibilityId: AccessibilityId?, action: @escaping () -> ()) {
        guard !expanded.value else { return }

        let actionIdx = actions.count
        actions.append(action)

        let button = UIButton(type: .custom)
        button.tag = actionIdx
        button.setImage(image, for: UIControlState())
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.accessibilityId = accessibilityId
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)

        buttons.append(button)

        let top = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal,
                                     toItem: self, attribute: .top,
                                     multiplier: 1, constant: marginForButtonAtIndex(actionIdx, expanded: expanded.value))
        topConstraints.append(top)
        let bottom = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .lessThanOrEqual,
                                        toItem: self, attribute: .bottom,
                                        multiplier: 1, constant: -buttonSpacing)
        let left = NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal,
                                        toItem: self, attribute: .leading,
                                        multiplier: 1, constant: buttonSpacing)
        let right = NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal,
                                       toItem: self, attribute: .trailing,
                                       multiplier: 1, constant: -buttonSpacing)
        let width = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal,
                                       toItem: nil, attribute: .notAnAttribute,
                                       multiplier: 1, constant: buttonSide)
        let height = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal,
                                        toItem: nil, attribute: .notAnAttribute,
                                        multiplier: 1, constant: buttonSide)
        addConstraints([top, bottom, left, right, width, height])
    }

    func expand(animated: Bool) {
        updateExpanded(true, animated: animated)
    }

    func shrink(animated: Bool) {
        updateExpanded(false, animated: animated)
    }

    func switchExpanded(animated: Bool) {
        if expanded.value {
            shrink(animated: animated)
        } else {
            expand(animated: animated)
        }
    }
}


// MARK: - Private methods

fileprivate extension ExpandableButtonsView {
    func setupUI() {
        alpha = 0
        clipsToBounds = true
        layer.cornerRadius = (buttonSide + buttonSpacing * 2) / 2
        backgroundColor = UIColor.white.withAlphaComponent(0.3)
    }

    func updateExpanded(_ expanded: Bool, animated: Bool) {
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
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5,
                                           options: [], animations: animations, completion: nil)
            } else {
                UIView.animate(withDuration: 0.25, animations: animations, completion: nil)
                UIView.animate(withDuration: 0.25, animations: animations)
            }
        } else {
            animations()
        }
    }

    func marginForButtonAtIndex(_ index: Int, expanded: Bool) -> CGFloat {
        return expanded ? (buttonSpacing + (buttonSpacing + buttonSide) * CGFloat(index)) : buttonSpacing
    }

    dynamic func buttonPressed(_ button: UIButton) {
        let actionIdx = button.tag
        guard 0..<actions.count ~= actionIdx else { return }

        actions[actionIdx]()
    }
}
