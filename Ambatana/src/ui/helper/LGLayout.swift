//
//  LGLayout.swift
//  LetGo
//
//  Created by Nestor Garcia on 27/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

typealias LGConstraintConfigurationBlock = (_ constraint: NSLayoutConstraint) -> ()

struct LGLayout {
    let owner: UIView
    let item1: Any
    let item2: Any?
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
    func left(to attribute: NSLayoutAttribute = .left, by constant: CGFloat = 0, multiplier: CGFloat = 1,
              relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
              constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .left, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func right(to attribute: NSLayoutAttribute = .right, by constant: CGFloat = 0, multiplier: CGFloat = 1,
               relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .right, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func top(to attribute: NSLayoutAttribute = .top, by constant: CGFloat = 0, multiplier: CGFloat = 1,
             relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .top, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func bottom(to attribute: NSLayoutAttribute = .bottom, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .bottom, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func leftMargin(to attribute: NSLayoutAttribute = .leftMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                    relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                    constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .leftMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func rightMargin(to attribute: NSLayoutAttribute = .rightMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                     relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                     constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .rightMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func topMargin(to attribute: NSLayoutAttribute = .topMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                   relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                   constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .topMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func bottomMargin(to attribute: NSLayoutAttribute = .bottomMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                      relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .bottomMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Leading, Trailing

    @discardableResult
    func leading(to attribute: NSLayoutAttribute = .leading, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                 relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .leading, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func trailing(to attribute: NSLayoutAttribute = .trailing, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                  relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                  constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .trailing, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func leadingMargin(to attribute: NSLayoutAttribute = .leadingMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                       relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .leadingMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func trailingMargin(to attribute: NSLayoutAttribute = .trailingMargin, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                        relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                        constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .trailingMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }


    // MARK: Center

    @discardableResult
    func centerX(to attribute: NSLayoutAttribute = .centerX, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                 relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerX, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func centerY(to attribute: NSLayoutAttribute = .centerY, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                 relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerY, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func centerXWithinMargin(to attribute: NSLayoutAttribute = .centerXWithinMargins, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                             relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerXWithinMargins, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func centerYWithinMargin(to attribute: NSLayoutAttribute = .centerYWithinMargins, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                             relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerYWithinMargins, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Baseline

    @discardableResult
    func lastBaseline(to attribute: NSLayoutAttribute = .lastBaseline, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                      relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .lastBaseline, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func firstBaseline(to attribute: NSLayoutAttribute = .firstBaseline, by constant: CGFloat = 0, multiplier: CGFloat = 1,
                       relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .firstBaseline, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }


    // MARK: Horizantal / Vertical arrangement

    @discardableResult
    func toRight(by constant: CGFloat = 0, multiplier: CGFloat = 1,
                 relatedBy: NSLayoutRelation = .equal,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .trailing, relatedBy: relatedBy, item2: item2, attribute2: .leading,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func toLeft(by constant: CGFloat = 0, multiplier: CGFloat = 1,
                relatedBy: NSLayoutRelation = .equal,
                priority: UILayoutPriority = UILayoutPriorityRequired,
                constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .trailing, relatedBy: relatedBy, item2: item2, attribute2: .leading,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func above(by constant: CGFloat = 0, multiplier: CGFloat = 1,
               relatedBy: NSLayoutRelation = .equal,
               priority: UILayoutPriority = UILayoutPriorityRequired,
               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .bottom, relatedBy: relatedBy, item2: item2, attribute2: .top,
                   constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func below(by constant: CGFloat = 0, multiplier: CGFloat = 1,
               relatedBy: NSLayoutRelation = .equal,
               priority: UILayoutPriority = UILayoutPriorityRequired,
               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
            constraint(item1: item1, attribute1: .top, relatedBy: relatedBy, item2: item2, attribute2: .bottom,
                       constant: constant, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Size

    @discardableResult
    func width(_ width: CGFloat, multiplier: CGFloat = 1,
               relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
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
    func height(_ height: CGFloat, multiplier: CGFloat = 1,
                relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
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
    func proportionalWidth(multiplier: CGFloat = 1, add: CGFloat = 0,
                           relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                           constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .width, relatedBy: relatedBy, item2: item2, attribute2: .width,
                   constant: add, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func proportionalHeight(multiplier: CGFloat = 1, add: CGFloat = 0,
                            relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                            constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .height, relatedBy: relatedBy, item2: item2, attribute2: .height,
                   constant: add, multiplier: multiplier, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func widthProportionalToHeight(multiplier: CGFloat = 1, add: CGFloat = 0, relatedBy: NSLayoutRelation = .equal,
                                   priority: UILayoutPriority = UILayoutPriorityRequired,
                                   constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .width, relatedBy: relatedBy,
                   item2: item1, attribute2: .height, constant: add, multiplier: multiplier,
                   priority: priority, constraintBlock: constraintBlock)
        return self
    }


    // MARK: Quick layout

    @discardableResult
    func fill() -> LGLayout {
        left()
        right()
        top()
        bottom()
        return self
    }

    @discardableResult
    func fillHorizontal(by constant: CGFloat = 0) -> LGLayout {
        return left(by: constant).right(by: -constant)
    }

    @discardableResult
    func fillVertical(by constant: CGFloat = 0) -> LGLayout {
        return top(by: constant).bottom(by: -constant)
    }

    @discardableResult
    func center() -> LGLayout {
        centerX()
        centerY()
        return self
    }
}

extension UIView {
    func layout() -> LGLayout {
        return LGLayout(owner: self, item1: self, item2: nil) // self
    }
    
    func layout(with item: Any) -> LGLayout {
        if let superview = self.superview {
            return LGLayout(owner: superview, item1: self, item2: item) // owner - brothers
        } else {
            assertionFailure("\(self) must have a superview")
            return LGLayout(owner: UIView(), item1: UIView(), item2: UIView())
        }
    }
    
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { subview in
            addSubview(subview)
        }
    }
    
    func setTranslatesAutoresizingMaskIntoConstraintsToFalse(for views: [UIView]) {
        views.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func addToViewController(_ viewController: UIViewController, inView: UIView) {
        inView.addSubview(self)
        layout(with: inView).left().right()
        layout(with: viewController.topLayoutGuide).top(to: .bottom)
        layout(with: viewController.bottomLayoutGuide).bottom(to: .top)
    }
}
