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
    private func constraint(item1: Any, attribute1: NSLayoutAttribute, relatedBy: NSLayoutRelation = .equal,
                            item2: Any? = nil, attribute2: NSLayoutAttribute = .notAnAttribute,
                            multiplier: CGFloat = 1, constant: CGFloat = 0,
                            priority: UILayoutPriority = UILayoutPriorityRequired,
                            constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
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
    func left(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .left, by constant: CGFloat = 0,
              priority: UILayoutPriority = UILayoutPriorityRequired,
              constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .left, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func right(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .right, by constant: CGFloat = 0,
               priority: UILayoutPriority = UILayoutPriorityRequired,
               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .right, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func top(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .top, by constant: CGFloat = 0,
             priority: UILayoutPriority = UILayoutPriorityRequired,
             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .top, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func bottom(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .bottom, by constant: CGFloat = 0,
                priority: UILayoutPriority = UILayoutPriorityRequired,
                constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .bottom, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func leftMargin(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .leftMargin, by constant: CGFloat = 0,
                    priority: UILayoutPriority = UILayoutPriorityRequired,
                    constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .leftMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func rightMargin(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .rightMargin, by constant: CGFloat = 0,
                     priority: UILayoutPriority = UILayoutPriorityRequired,
                     constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .rightMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func topMargin(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .topMargin, by constant: CGFloat = 0,
                   priority: UILayoutPriority = UILayoutPriorityRequired,
                   constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .topMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func bottomMargin(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .bottomMargin, by constant: CGFloat = 0,
                      priority: UILayoutPriority = UILayoutPriorityRequired,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .bottomMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Leading, Trailing

    @discardableResult
    func leading(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .leading, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .leading, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func trailing(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .trailing, by constant: CGFloat = 0,
                  priority: UILayoutPriority = UILayoutPriorityRequired,
                  constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .trailing, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func leadingMargin(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .leadingMargin, by constant: CGFloat = 0,
                       priority: UILayoutPriority = UILayoutPriorityRequired,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .leadingMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func trailingMargin(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .trailingMargin, by constant: CGFloat = 0,
                        priority: UILayoutPriority = UILayoutPriorityRequired,
                        constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .trailingMargin, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }


    // MARK: Center

    @discardableResult
    func centerX(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .centerX, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerX, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func centerY(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .centerY, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerY, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func centerXWithinMargin(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .centerXWithinMargins, by constant: CGFloat = 0,
                             priority: UILayoutPriority = UILayoutPriorityRequired,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerXWithinMargins, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func centerYWithinMargin(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .centerYWithinMargins, by constant: CGFloat = 0,
                             priority: UILayoutPriority = UILayoutPriorityRequired,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .centerYWithinMargins, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Baseline

    @discardableResult
    func lastBaseline(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .lastBaseline, by constant: CGFloat = 0,
                      priority: UILayoutPriority = UILayoutPriorityRequired,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .lastBaseline, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func firstBaseline(relatedBy: NSLayoutRelation = .equal, to attribute: NSLayoutAttribute = .firstBaseline, by constant: CGFloat = 0,
                       priority: UILayoutPriority = UILayoutPriorityRequired,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .firstBaseline, relatedBy: relatedBy, item2: item2, attribute2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Size

    @discardableResult
    func width(_ width: CGFloat, relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .width, relatedBy: relatedBy, constant: width, priority: priority, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func height(_ height: CGFloat, relatedBy: NSLayoutRelation = .equal, priority: UILayoutPriority = UILayoutPriorityRequired,
                constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attribute1: .height, relatedBy: relatedBy, constant: height, priority: priority, constraintBlock: constraintBlock)
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
    func center() -> LGLayout {
        centerX()
        centerY()
        return self
    }

    @discardableResult
    func widthEqualsHeight(size: CGFloat) -> LGLayout {
        constraint(item1: item1, attribute1: .width, item2: item1, attribute2: .height)
        constraint(item1: item1, attribute1: .width, constant: size)
        return self
    }
}

extension UIView {
    
    func layout(with item: Any? = nil) -> LGLayout {
        if item == nil {
            return LGLayout(owner: self, item1: self, item2: nil) // self
        } else if let superview = self.superview {
            if let item = item {
                return LGLayout(owner: superview, item1: self, item2: item) // owner - brothers
            } else {
                return LGLayout(owner: superview, item1: self, item2: superview) // child - owner
            }
        } else {
            assertionFailure("\(self) must have a superview")
            return LGLayout(owner: UIView(), item1: UIView(), item2: UIView())
        }
    }
    
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { (subview) in
            addSubview(subview)
        }
    }
    
    func setTranslatesAutoresizingMaskIntoConstraintsToFalse(for views: [UIView]) {
        views.forEach { (view) in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func addToViewController(_ viewController: UIViewController, inView: UIView) {
        inView.addSubview(self)
        self.layout(with: inView).left().right()
        self.layout(with: viewController.topLayoutGuide).top(to: .bottom)
        self.layout(with: viewController.bottomLayoutGuide).bottom(to: .top)
    }
}
