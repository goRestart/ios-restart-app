//
//  UIView+Constraints.swift
//  LetGo
//
//  Created by Eli Kohen on 30/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


extension UIView {

    func fitHorizontallyToParent(margin margin: CGFloat = 0) -> [NSLayoutConstraint] {
        let views = ["view" : self]
        let metrics = [ "margin" : margin ]
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[view]-margin-|", options: [], metrics: metrics, views: views)
        superview?.addConstraints(constraints)
        return constraints
    }

    func fitVerticallyToParent(margin margin: CGFloat = 0) -> [NSLayoutConstraint] {
        let views = ["view" : self]
        let metrics = [ "margin" : margin ]
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[view]-margin-|", options: [], metrics: metrics, views: views)
        superview?.addConstraints(constraints)
        return constraints
    }

    func alignParentLeft(margin margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: superview, attribute: .Left, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    func alignParentRight(margin margin: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = superview else { return NSLayoutConstraint() }
        let constraint = NSLayoutConstraint(item: superview, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: margin)
        superview.addConstraint(constraint)
        return constraint
    }

    func alignParentTop(margin margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    func alignParentBottom(margin margin: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = superview else { return NSLayoutConstraint() }
        let constraint = NSLayoutConstraint(item: superview, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: margin)
        superview.addConstraint(constraint)
        return constraint
    }

    func centerParentHorizontal(offset offset: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: superview, attribute: .CenterX, multiplier: 1, constant: offset)
        superview?.addConstraint(constraint)
        return constraint
    }

    func centerParentVertical(offset offset: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: superview, attribute: .CenterY, multiplier: 1, constant: offset)
        superview?.addConstraint(constraint)
        return constraint
    }

    func toRightOf(view: UIView, margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    func toLeftOf(view: UIView, margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    func toTopOf(view: UIView, margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    func toBottomOf(view: UIView, margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    func setMinHeight(height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height)
        addConstraint(constraint)
        return constraint
    }

    func setMaxHeight(height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height)
        addConstraint(constraint)
        return constraint
    }

    func setHeightConstraint(height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height)
        addConstraint(constraint)
        return constraint
    }

    func setWidthConstraint(width: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: width)
        addConstraint(constraint)
        return constraint
    }

    func setWidthConstraint(multiplier multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint {
        guard let superview = superview else { return NSLayoutConstraint() }
        let constraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: superview, attribute: .Width, multiplier: multiplier, constant: constant)
        superview.addConstraint(constraint)
        return constraint
    }

}
