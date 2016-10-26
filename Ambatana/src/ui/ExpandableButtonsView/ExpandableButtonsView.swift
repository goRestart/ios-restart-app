//
//  ExpandableButtonsView.swift
//  LetGo
//
//  Created by Albert Hernández López on 25/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

enum ShareMedium {
    case SMS, Email, Facebook, WhatsApp, FBMessenger, Twitter
}

class ExpandableButtonsView: UIView {
    enum Direction {
        case Up, Down, Left, Right

        var isVertical: Bool {
            switch self {
            case .Down, .Up:
                return true
            case .Left, .Right:
                return false
            }
        }
    }

    private var buttons: [UIButton] = []
    private var actions: [() -> ()] = []

    private let buttonSide: CGFloat
    private let buttonSpacing: CGFloat
    private let direction: Direction
    let expanded = Variable<Bool>(false)
    var animate = true

    private var topConstraints: [NSLayoutConstraint] = []
    private var bottomConstraints: [NSLayoutConstraint] = []
    private var leftConstraints: [NSLayoutConstraint] = []
    private var rightConstraints: [NSLayoutConstraint] = []
    private var widthConstraints: [NSLayoutConstraint] = []
    private var heightConstraints: [NSLayoutConstraint] = []

    private let disposeBag: DisposeBag = DisposeBag()


    // MARK: - Lifecycle

    init(buttonSide: CGFloat, buttonSpacing: CGFloat) {
        self.buttonSide = buttonSide
        self.buttonSpacing = buttonSpacing
        self.direction = .Down
        super.init(frame: CGRect.zero)
        setupUI()
        setupRx()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let minSide = min(1, min(height, width))    // min 1 to prevent div by 0
        layer.cornerRadius = minSide / 2
    }
}


// MARK: - Public methods

extension ExpandableButtonsView {
    func addButton(image image: UIImage?, bgColor: UIColor?, action: () -> ()) {
        guard !expanded.value else { return }

        let actionIdx = actions.count
        actions.append(action)

        let button = UIButton(type: .Custom)
        button.tag = actionIdx
        button.setImage(image, forState: .Normal)
        button.setBackgroundImage(bgColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        button.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)

        buttons.append(button)

        let top = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal,
                                     toItem: self, attribute: .Top,
                                     multiplier: 1, constant: direction.isVertical ? buttonSpacing : 0)
        topConstraints.append(top)
        let bottom = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal,
                                        toItem: self, attribute: .Bottom,
                                        multiplier: 1, constant: direction.isVertical ? 0 : buttonSpacing)
        bottomConstraints.append(bottom)
        let left = NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal,
                                        toItem: self, attribute: .Leading,
                                        multiplier: 1, constant: direction.isVertical ? 0 : buttonSpacing)
        leftConstraints.append(left)
        let right = NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal,
                                       toItem: self, attribute: .Trailing,
                                       multiplier: 1, constant: direction.isVertical ? buttonSpacing : 0)
        rightConstraints.append(right)
        let width = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal,
                                       toItem: nil, attribute: .NotAnAttribute,
                                       multiplier: 1, constant: direction.isVertical ? buttonSpacing : 0)
        widthConstraints.append(width)
        let height = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal,
                                        toItem: nil, attribute: .NotAnAttribute,
                                        multiplier: 1, constant: direction.isVertical ? 0 : buttonSide)
        heightConstraints.append(height)
        addConstraints([top, bottom, left, right, width, height])
    }

    func switchExpanded() {
        expanded.value = !expanded.value
    }
}


// MARK: - Private methods

private extension ExpandableButtonsView {
    var marginConstraintsToEdit: [NSLayoutConstraint] {
        switch direction {
        case .Up:
            return bottomConstraints
        case .Down:
            return topConstraints
        case .Left:
            return rightConstraints
        case .Right:
            return leftConstraints
        }
    }
    var sideConstraintsToEdit: [NSLayoutConstraint] {
        if direction.isVertical {
            return heightConstraints
        } else {
            return widthConstraints
        }
    }

    func setupUI() {
        clipsToBounds = true
        backgroundColor = UIColor.white.colorWithAlphaComponent(0.3)
    }

    func setupRx() {
        let alpha = expanded.asObservable().map { CGFloat($0 ? 1.0 : 0.0) }
        alpha.bindTo(rx_alpha).addDisposableTo(disposeBag)

        let marginsAndSides = expanded.asObservable().map { [weak self] (expanded: Bool) -> [(CGFloat, CGFloat)] in
            guard let strongSelf = self else { return [] }
            return (0..<strongSelf.buttons.count).map {
                return (strongSelf.marginForButtonAtIndex($0, expanded: expanded), strongSelf.sideForButton(expanded))
            }
        }
        marginsAndSides.subscribeNext { [weak self] marginsAndSides in
            guard let strongSelf = self else { return }
            (0..<marginsAndSides.count).forEach {
                strongSelf.marginConstraintsToEdit[$0].constant = marginsAndSides[$0].0
                strongSelf.sideConstraintsToEdit[$0].constant = marginsAndSides[$0].1
            }
            if strongSelf.animate {
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5,
                    options: [], animations: { [weak self] in self?.layoutIfNeeded() }, completion: nil)
            } else {
                strongSelf.layoutIfNeeded()
            }
        }.addDisposableTo(disposeBag)
    }

    func marginForButtonAtIndex(index: Int, expanded: Bool) -> CGFloat {
        return expanded ? (buttonSpacing + buttonSide) * CGFloat(index + 1) : 0
    }

    func sideForButton(expanded: Bool) -> CGFloat {
        return expanded ? buttonSide : 0
    }

    dynamic func buttonPressed(button: UIButton) {
        let actionIdx = button.tag
        guard 0..<actions.count ~= actionIdx else { return }

        actions[actionIdx]()
    }
}
