//
//  LGLayout.swift
//  LetGo
//
//  Created by Nestor Garcia on 27/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

public typealias LGConstraintConfigurationBlock = (_ constraint: NSLayoutConstraint) -> ()

public struct LGLayout {
    public let owner: UIView
    public let item1: Any
    public let item2: Any?
}

extension LGLayout {
    
    // MARK: Helpers
    
    @discardableResult
    private func constraint(item1: Any, attribute1: NSLayoutAttribute, relatedBy: NSLayoutRelation,
                            item2: Any? = nil, attribute2: NSLayoutAttribute = .notAnAttribute,
                            constant: CGFloat, multiplier: CGFloat, priority: UILayoutPriority,
                            constraintBlock: LGConstraintConfigurationBlock?) -> LGLayout {
        let layoutConstraint = NSLayoutConstraint(item: item1,
                                                  attribute: attribute1,
                                                  relatedBy: relatedBy,
                                                  toItem: item2,
                                                  attribute: attribute2,
                                                  multiplier: multiplier,
                                                  constant: constant)
        layoutConstraint.priority = priority
        constraintBlock?(layoutConstraint)
        owner.addConstraint(layoutConstraint)
        return self
    }
    
    // MARK: Left, Right, Top, Bottom

    @discardableResult
    public func left(to attribute: NSLayoutAttribute = .left, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                     relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                     constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .left, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func right(to attribute: NSLayoutAttribute = .right, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                      relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .right, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func top(to attribute: NSLayoutAttribute = .top, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                    relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                    constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .top, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func bottom(to attribute: NSLayoutAttribute = .bottom, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                       relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .bottom, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func leftMargin(to attribute: NSLayoutAttribute = .leftMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                           relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                           constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .leftMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func rightMargin(to attribute: NSLayoutAttribute = .rightMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                            relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                            constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .rightMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func topMargin(to attribute: NSLayoutAttribute = .topMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                          relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                          constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .topMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func bottomMargin(to attribute: NSLayoutAttribute = .bottomMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                             relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .bottomMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Leading, Trailing

    @discardableResult
    public func leading(to attribute: NSLayoutAttribute = .leading, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                        relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                        constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .leading, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func trailing(to attribute: NSLayoutAttribute = .trailing, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                         relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                         constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .trailing, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func leadingMargin(to attribute: NSLayoutAttribute = .leadingMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                              relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                              constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .leadingMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func trailingMargin(to attribute: NSLayoutAttribute = .trailingMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                               relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .trailingMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }


    // MARK: Center

    @discardableResult
    public func centerX(to attribute: NSLayoutAttribute = .centerX, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                        relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                        constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerX, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func centerY(to attribute: NSLayoutAttribute = .centerY, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                        relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                        constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerY, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func centerXWithinMargin(to attribute: NSLayoutAttribute = .centerXWithinMargins, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                                    relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                                    constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerXWithinMargins, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func centerYWithinMargin(to attribute: NSLayoutAttribute = .centerYWithinMargins, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                                    relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                                    constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerYWithinMargins, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Baseline

    @discardableResult
    public func lastBaseline(to attribute: NSLayoutAttribute = .lastBaseline, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                             relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .lastBaseline, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func firstBaseline(to attribute: NSLayoutAttribute = .firstBaseline, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                              relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                              constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .firstBaseline, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }


    // MARK: Horizontal / Vertical arrangement

    @discardableResult
    public func toRight(by constant: CGFloat = 0, multiplier: CGFloat = 1,
                        relatedBy: NSLayoutRelation = .equal,
                        priority: UILayoutPriority = UILayoutPriority.required,
                        constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .trailing, relatedBy: relatedBy, item2: item2, attribute2: .leading,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func toLeft(by constant: CGFloat = 0, multiplier: CGFloat = 1,
                       relatedBy: NSLayoutRelation = .equal,
                       priority: UILayoutPriority = UILayoutPriority.required,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .leading, relatedBy: relatedBy, item2: item2, attribute2: .trailing,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func above(by constant: CGFloat = 0, multiplier: CGFloat = 1,
                relatedBy: NSLayoutRelation = .equal,
                priority: UILayoutPriority = UILayoutPriority.required,
                constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .bottom, relatedBy: relatedBy, item2: item2, attribute2: .top,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func below(by constant: CGFloat = 0, multiplier: CGFloat = 1,
                      relatedBy: NSLayoutRelation = .equal,
                      priority: UILayoutPriority = UILayoutPriority.required,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
            constraint(item1: item1, attribute1: .top, relatedBy: relatedBy, item2: item2, attribute2: .bottom,
                       constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Size

    @discardableResult
    public func width(_ width: CGFloat, multiplier: CGFloat = 1,
                      relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        if let item2 = item2 {
            constraint(item1: item1, attribute1: .width, relatedBy: relatedBy, item2: item2, attribute2: .width, constant: width, multiplier: multiplier,
                       priority: priority, constraintBlock: constraintBlock)
        } else {
            constraint(item1: item1, attribute1: .width, relatedBy: relatedBy, constant: width, multiplier: multiplier,
                       priority: priority, constraintBlock: constraintBlock)
        }
        return self
    }

    @discardableResult
    public func height(_ height: CGFloat, multiplier: CGFloat = 1,
                       relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        if let item2 = item2 {
            constraint(item1: item1, attribute1: .height, relatedBy: relatedBy, item2: item2, attribute2: .height, constant: height, multiplier: multiplier,
                       priority: priority, constraintBlock: constraintBlock)
        } else {
            constraint(item1: item1, attribute1: .height, relatedBy: relatedBy, constant: height, multiplier: multiplier,
                       priority: priority, constraintBlock: constraintBlock)
        }
        return self
    }

    @discardableResult
    public func proportionalWidth(multiplier: CGFloat = 1, add: CGFloat = 0,
                                  relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                                  constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .width, relatedBy: relatedBy, item2: item2, attribute2: .width,
                   constant: add, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func proportionalHeight(multiplier: CGFloat = 1, add: CGFloat = 0,
                                   relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriority.required,
                                   constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .height, relatedBy: relatedBy, item2: item2, attribute2: .height,
                   constant: add, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    public func widthProportionalToHeight(multiplier: CGFloat = 1, add: CGFloat = 0, relatedBy: NSLayoutRelation = .equal,
                                          priority: UILayoutPriority = UILayoutPriority.required,
                                          constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .width, relatedBy: relatedBy,
                   item2: item1, attribute2: .height, constant: add, multiplier: multiplier,
                   priority: priority, constraintBlock: constraintBlock)
        return self
    }


    // MARK: Quick layout

    @discardableResult
    public func fill(by constant: CGFloat = 0) -> LGLayout {
        left(by: constant)
        right(by: -constant)
        top(by: constant)
        bottom(by: -constant)
        return self
    }

    @discardableResult
    public func fillHorizontal(by constant: CGFloat = 0) -> LGLayout {
        return left(by: constant).right(by: -constant)
    }

    @discardableResult
    public func fillVertical(by constant: CGFloat = 0) -> LGLayout {
        return top(by: constant).bottom(by: -constant)
    }

    @discardableResult
    public func center() -> LGLayout {
        centerX()
        centerY()
        return self
    }
}

extension UIView {
    public func layout() -> LGLayout {
        return LGLayout(owner: self, item1: self, item2: nil) // self
    }
    
    public func layout(with item: Any) -> LGLayout {
        if let superview = self.superview {
            return LGLayout(owner: superview, item1: self, item2: item) // owner - brothers
        } else {
            assertionFailure("\(self) must have a superview")
            return LGLayout(owner: UIView(), item1: UIView(), item2: UIView())
        }
    }

    public func addSubviewForAutoLayout(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }

    public func addSubviewsForAutoLayout(_ subviews: [UIView]) {
        subviews.forEach { subview in
            addSubviewForAutoLayout(subview)
        }
    }

    public func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { subview in
            addSubview(subview)
        }
    }
    
    public func setTranslatesAutoresizingMaskIntoConstraintsToFalse(for views: [UIView]) {
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    public func addToViewController(_ viewController: UIViewController, inView: UIView) {
        inView.addSubview(self)
        layout(with: inView).left().right()
        layout(with: viewController.topLayoutGuide).top(to: .bottom)
        layout(with: viewController.bottomLayoutGuide).bottom(to: .top)
    }
}

extension UIViewController {
    public var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        }
        else {
            return topLayoutGuide.bottomAnchor
        }
    }

    public var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.bottomAnchor
        }
        else {
            return bottomLayoutGuide.topAnchor
        }
    }

    public var safeTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.trailingAnchor
        }
        else {
            return view.trailingAnchor
        }
    }

    public var safeLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.leadingAnchor
        }
        else {
            return view.leadingAnchor
        }
    }

    public func constraintViewToSafeRootView(_ view: UIView) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: safeTopAnchor),
            view.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
            view.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            view.leadingAnchor.constraint(equalTo: safeLeadingAnchor)
        ])
    }
}
