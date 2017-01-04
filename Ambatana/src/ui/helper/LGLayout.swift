//
//  LGLayout.swift
//  LetGo
//
//  Created by Nestor Garcia on 27/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

typealias LGConstraintConfigurationBlock = (_ constraint: NSLayoutConstraint) -> ()

class LGLayout {
    let owner: UIView
    let item1: AnyObject
    let item2: AnyObject?
    
    private var constraints: [NSLayoutConstraint] = []
    
    init(owner: UIView, item1: AnyObject, item2: AnyObject?) {
        self.owner = owner
        self.item1 = item1
        self.item2 = item2
    }
    
    init() {
        self.owner = UIView()
        self.item1 = UIView()
        self.item2 = UIView()
    }
}

extension LGLayout {
    
    // MARK: Helpers
    
    func apply() {
        owner.addConstraints(constraints)
    }
    
    private func constraint(item1: AnyObject, attritube1: NSLayoutAttribute, relatedBy: NSLayoutRelation = .equal,
                            item2: AnyObject? = nil, attritube2: NSLayoutAttribute = .notAnAttribute,
                            multiplier: CGFloat = 1, constant: CGFloat = 0,
                            priority: UILayoutPriority = UILayoutPriorityRequired,
                            constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        let layoutConstraint = NSLayoutConstraint(item: item1,
                                                  attribute: attritube1,
                                                  relatedBy: relatedBy,
                                                  toItem: item2,
                                                  attribute: attritube2,
                                                  multiplier: multiplier,
                                                  constant: constant)
        layoutConstraint.priority = priority
        constraints.append(layoutConstraint)
        constraintBlock?(layoutConstraint)
        return self
    }
    
    // MARK: Left, Right, Top, Bottom
    
    func left(to attribute: NSLayoutAttribute = .left, by constant: CGFloat = 0,
              priority: UILayoutPriority = UILayoutPriorityRequired,
              constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .left, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func right(to attribute: NSLayoutAttribute = .right, by constant: CGFloat = 0,
               priority: UILayoutPriority = UILayoutPriorityRequired,
               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .right, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func top(to attribute: NSLayoutAttribute = .top, by constant: CGFloat = 0,
             priority: UILayoutPriority = UILayoutPriorityRequired,
             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .top, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func bottom(to attribute: NSLayoutAttribute = .bottom, by constant: CGFloat = 0,
                priority: UILayoutPriority = UILayoutPriorityRequired,
                constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .bottom, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func leftMargin(to attribute: NSLayoutAttribute = .leftMargin, by constant: CGFloat = 0,
                    priority: UILayoutPriority = UILayoutPriorityRequired,
                    constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .leftMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func rightMargin(to attribute: NSLayoutAttribute = .rightMargin, by constant: CGFloat = 0,
                     priority: UILayoutPriority = UILayoutPriorityRequired,
                     constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .rightMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func topMargin(to attribute: NSLayoutAttribute = .topMargin, by constant: CGFloat = 0,
                   priority: UILayoutPriority = UILayoutPriorityRequired,
                   constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .topMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func bottomMargin(to attribute: NSLayoutAttribute = .bottomMargin, by constant: CGFloat = 0,
                      priority: UILayoutPriority = UILayoutPriorityRequired,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .bottomMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    // MARK: Leading, Trailing
    
    func leading(to attribute: NSLayoutAttribute = .leading, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .leading, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func trailing(to attribute: NSLayoutAttribute = .trailing, by constant: CGFloat = 0,
                  priority: UILayoutPriority = UILayoutPriorityRequired,
                  constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .trailing, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func leadingMargin(to attribute: NSLayoutAttribute = .leadingMargin, by constant: CGFloat = 0,
                       priority: UILayoutPriority = UILayoutPriorityRequired,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .leadingMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func trailingMargin(to attribute: NSLayoutAttribute = .trailingMargin, by constant: CGFloat = 0,
                        priority: UILayoutPriority = UILayoutPriorityRequired,
                        constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .trailingMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    // MARK: Center
    
    func centerX(to attribute: NSLayoutAttribute = .centerX, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .centerX, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func centerY(to attribute: NSLayoutAttribute = .centerY, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .centerY, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func centerXWithinMargin(to attribute: NSLayoutAttribute = .centerXWithinMargins, by constant: CGFloat = 0,
                             priority: UILayoutPriority = UILayoutPriorityRequired,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .centerXWithinMargins, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func centerYWithinMargin(to attribute: NSLayoutAttribute = .centerYWithinMargins, by constant: CGFloat = 0,
                             priority: UILayoutPriority = UILayoutPriorityRequired,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .centerYWithinMargins, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    // MARK: Baseline
    
    func lastBaseline(to attribute: NSLayoutAttribute = .lastBaseline, by constant: CGFloat = 0,
                      priority: UILayoutPriority = UILayoutPriorityRequired,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .lastBaseline, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func firstBaseline(to attribute: NSLayoutAttribute = .firstBaseline, by constant: CGFloat = 0,
                       priority: UILayoutPriority = UILayoutPriorityRequired,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .firstBaseline, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    // MARK: Size
    
    func width(_ width: CGFloat, priority: UILayoutPriority = UILayoutPriorityRequired,
               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .width, constant: width, priority: priority, constraintBlock: constraintBlock)
        return self
    }
    
    func height(_ height: CGFloat, priority: UILayoutPriority = UILayoutPriorityRequired,
                constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .height, constant: height, priority: priority, constraintBlock: constraintBlock)
        return self
    }
    
    // MARK: Quick layout
    
    func fill() -> LGLayout {
        left()
        right()
        top()
        bottom()
        return self
    }
    
    func center() -> LGLayout {
        centerX()
        centerY()
        return self
    }
    
    func widthEqualsHeight() -> LGLayout {
        constraint(item1: item1, attritube1: .width, item2: item1, attritube2: .height)
        return self
    }
}

extension UIView {
    
    func layout(with item: AnyObject? = nil) -> LGLayout {
        self.translatesAutoresizingMaskIntoConstraints = false
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
            return LGLayout()
        }
    }
}
