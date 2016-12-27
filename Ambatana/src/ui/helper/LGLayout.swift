//
//  LGLayout.swift
//  LetGo
//
//  Created by Nestor Garcia on 27/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

typealias LGConstraintConfigurationBlock = (constraint: NSLayoutConstraint) -> ()

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
    
    private func constraint(item1 item1: AnyObject, attritube1: NSLayoutAttribute, relatedBy: NSLayoutRelation = .Equal,
                            item2: AnyObject? = nil, attritube2: NSLayoutAttribute = .NotAnAttribute,
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
        constraintBlock?(constraint: layoutConstraint)
        return self
    }
    
    // MARK: Left, Right, Top, Bottom
    
    func left(to attribute: NSLayoutAttribute = .Left, by constant: CGFloat = 0,
              priority: UILayoutPriority = UILayoutPriorityRequired,
              constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .Left, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func right(to attribute: NSLayoutAttribute = .Right, by constant: CGFloat = 0,
               priority: UILayoutPriority = UILayoutPriorityRequired,
               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .Right, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func top(to attribute: NSLayoutAttribute = .Top, by constant: CGFloat = 0,
             priority: UILayoutPriority = UILayoutPriorityRequired,
             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .Top, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func bottom(to attribute: NSLayoutAttribute = .Bottom, by constant: CGFloat = 0,
                priority: UILayoutPriority = UILayoutPriorityRequired,
                constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .Bottom, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func leftMargin(to attribute: NSLayoutAttribute = .LeftMargin, by constant: CGFloat = 0,
                    priority: UILayoutPriority = UILayoutPriorityRequired,
                    constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .LeftMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func rightMargin(to attribute: NSLayoutAttribute = .RightMargin, by constant: CGFloat = 0,
                     priority: UILayoutPriority = UILayoutPriorityRequired,
                     constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .RightMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func topMargin(to attribute: NSLayoutAttribute = .TopMargin, by constant: CGFloat = 0,
                   priority: UILayoutPriority = UILayoutPriorityRequired,
                   constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .TopMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func bottomMargin(to attribute: NSLayoutAttribute = .BottomMargin, by constant: CGFloat = 0,
                      priority: UILayoutPriority = UILayoutPriorityRequired,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .BottomMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    // MARK: Leading, Trailing
    
    func leading(to attribute: NSLayoutAttribute = .Leading, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .Leading, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func trailing(to attribute: NSLayoutAttribute = .Trailing, by constant: CGFloat = 0,
                  priority: UILayoutPriority = UILayoutPriorityRequired,
                  constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .Trailing, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func leadingMargin(to attribute: NSLayoutAttribute = .LeadingMargin, by constant: CGFloat = 0,
                       priority: UILayoutPriority = UILayoutPriorityRequired,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .LeadingMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func trailingMargin(to attribute: NSLayoutAttribute = .TrailingMargin, by constant: CGFloat = 0,
                        priority: UILayoutPriority = UILayoutPriorityRequired,
                        constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .TrailingMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    // MARK: Center
    
    func centerX(to attribute: NSLayoutAttribute = .CenterX, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .CenterX, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func centerY(to attribute: NSLayoutAttribute = .CenterY, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .CenterY, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func centerXWithinMargin(to attribute: NSLayoutAttribute = .CenterXWithinMargins, by constant: CGFloat = 0,
                             priority: UILayoutPriority = UILayoutPriorityRequired,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .CenterXWithinMargins, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func centerYWithinMargin(to attribute: NSLayoutAttribute = .CenterYWithinMargins, by constant: CGFloat = 0,
                             priority: UILayoutPriority = UILayoutPriorityRequired,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .CenterYWithinMargins, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    // MARK: Baseline
    
    func lastBaseline(to attribute: NSLayoutAttribute = .LastBaseline, by constant: CGFloat = 0,
                      priority: UILayoutPriority = UILayoutPriorityRequired,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .LastBaseline, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    func FirstBaseline(to attribute: NSLayoutAttribute = .FirstBaseline, by constant: CGFloat = 0,
                       priority: UILayoutPriority = UILayoutPriorityRequired,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .FirstBaseline, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }
    
    // MARK: Size
    
    func width(width: CGFloat, priority: UILayoutPriority = UILayoutPriorityRequired,
               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .Width, constant: width, priority: priority, constraintBlock: constraintBlock)
        return self
    }
    
    func height(height: CGFloat, priority: UILayoutPriority = UILayoutPriorityRequired,
                constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .Height, constant: height, priority: priority, constraintBlock: constraintBlock)
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
        constraint(item1: item1, attritube1: .Width, item2: item1, attritube2: .Height)
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
