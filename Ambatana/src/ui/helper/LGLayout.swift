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
    private func constraint(item1: Any, attritube1: NSLayoutAttribute, relatedBy: NSLayoutRelation = .equal,
                            item2: Any? = nil, attritube2: NSLayoutAttribute = .notAnAttribute,
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
    func left(to attribute: NSLayoutAttribute = .left, by constant: CGFloat = 0,
              priority: UILayoutPriority = UILayoutPriorityRequired,
              constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .left, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func right(to attribute: NSLayoutAttribute = .right, by constant: CGFloat = 0,
               priority: UILayoutPriority = UILayoutPriorityRequired,
               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .right, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func top(to attribute: NSLayoutAttribute = .top, by constant: CGFloat = 0,
             priority: UILayoutPriority = UILayoutPriorityRequired,
             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .top, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func bottom(to attribute: NSLayoutAttribute = .bottom, by constant: CGFloat = 0,
                priority: UILayoutPriority = UILayoutPriorityRequired,
                constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .bottom, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func leftMargin(to attribute: NSLayoutAttribute = .leftMargin, by constant: CGFloat = 0,
                    priority: UILayoutPriority = UILayoutPriorityRequired,
                    constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .leftMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func rightMargin(to attribute: NSLayoutAttribute = .rightMargin, by constant: CGFloat = 0,
                     priority: UILayoutPriority = UILayoutPriorityRequired,
                     constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
        constraint(item1: item1, attritube1: .rightMargin, item2: item2, attritube2: attribute,
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func topMargin(to attribute: NSLayoutAttribute = .topMargin, by constant: CGFloat = 0,
                   priority: UILayoutPriority = UILayoutPriorityRequired,
                   constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .TopMargin, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .topMargin, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func bottomMargin(to attribute: NSLayoutAttribute = .bottomMargin, by constant: CGFloat = 0,
                      priority: UILayoutPriority = UILayoutPriorityRequired,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .BottomMargin, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .bottomMargin, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Leading, Trailing

    @discardableResult
    func leading(to attribute: NSLayoutAttribute = .leading, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .Leading, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .leading, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func trailing(to attribute: NSLayoutAttribute = .trailing, by constant: CGFloat = 0,
                  priority: UILayoutPriority = UILayoutPriorityRequired,
                  constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .Trailing, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .trailing, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func leadingMargin(to attribute: NSLayoutAttribute = .leadingMargin, by constant: CGFloat = 0,
                       priority: UILayoutPriority = UILayoutPriorityRequired,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .LeadingMargin, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .leadingMargin, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func trailingMargin(to attribute: NSLayoutAttribute = .trailingMargin, by constant: CGFloat = 0,
                        priority: UILayoutPriority = UILayoutPriorityRequired,
                        constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .TrailingMargin, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .trailingMargin, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }


    // MARK: Center

    @discardableResult
    func centerX(to attribute: NSLayoutAttribute = .centerX, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .CenterX, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .centerX, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func centerY(to attribute: NSLayoutAttribute = .centerY, by constant: CGFloat = 0,
                 priority: UILayoutPriority = UILayoutPriorityRequired,
                 constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .CenterY, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .centerY, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func centerXWithinMargin(to attribute: NSLayoutAttribute = .centerXWithinMargins, by constant: CGFloat = 0,
                             priority: UILayoutPriority = UILayoutPriorityRequired,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .CenterXWithinMargins, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .centerXWithinMargins, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func centerYWithinMargin(to attribute: NSLayoutAttribute = .centerYWithinMargins, by constant: CGFloat = 0,
                             priority: UILayoutPriority = UILayoutPriorityRequired,
                             constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .CenterYWithinMargins, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .centerYWithinMargins, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Baseline

    @discardableResult
    func lastBaseline(to attribute: NSLayoutAttribute = .lastBaseline, by constant: CGFloat = 0,
                      priority: UILayoutPriority = UILayoutPriorityRequired,
                      constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .LastBaseline, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .lastBaseline, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    @discardableResult
    func firstBaseline(to attribute: NSLayoutAttribute = .firstBaseline, by constant: CGFloat = 0,
                       priority: UILayoutPriority = UILayoutPriorityRequired,
                       constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .FirstBaseline, item2: item2, attribute2: attribute,
=======
        constraint(item1: item1, attritube1: .firstBaseline, item2: item2, attritube2: attribute,
>>>>>>> develop
                   constant: constant, constraintBlock: constraintBlock)
        return self
    }

    
    // MARK: Size

    @discardableResult
    func width(_ width: CGFloat, priority: UILayoutPriority = UILayoutPriorityRequired,
               constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .Width, constant: width, priority: priority, constraintBlock: constraintBlock)
=======
        constraint(item1: item1, attritube1: .width, constant: width, priority: priority, constraintBlock: constraintBlock)
>>>>>>> develop
        return self
    }

    @discardableResult
    func height(_ height: CGFloat, priority: UILayoutPriority = UILayoutPriorityRequired,
                constraintBlock: LGConstraintConfigurationBlock? = nil) -> LGLayout {
<<<<<<< HEAD
        constraint(item1: item1, attribute1: .Height, constant: height, priority: priority, constraintBlock: constraintBlock)
=======
        constraint(item1: item1, attritube1: .height, constant: height, priority: priority, constraintBlock: constraintBlock)
>>>>>>> develop
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
<<<<<<< HEAD
    
    func widthEqualsHeight() -> LGLayout {
        constraint(item1: item1, attribute1: .Width, item2: item1, attribute2: .Height)
=======

    @discardableResult
    func widthEqualsHeight(size: CGFloat) -> LGLayout {
        constraint(item1: item1, attritube1: .width, item2: item1, attritube2: .height)
        constraint(item1: item1, attritube1: .width, constant: size)
>>>>>>> develop
        return self
    }
}

extension UIView {
    
    func layout(with item: Any? = nil) -> LGLayout {
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
            return LGLayout(owner: UIView(), item1: UIView(), item2: UIView())
        }
    }
}
