//
//  UIView+Constraints.swift
//  LetGo
//
//  Created by Eli Kohen on 30/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


extension UIView {

    @discardableResult func fitHorizontallyToParent(margin: CGFloat = 0) -> [NSLayoutConstraint] {
        let views = ["view" : self]
        let metrics = [ "margin" : margin ]
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[view]-margin-|", options: [], metrics: metrics, views: views)
        superview?.addConstraints(constraints)
        return constraints
    }

    @discardableResult func fitVerticallyToParent(margin: CGFloat = 0) -> [NSLayoutConstraint] {
        let views = ["view" : self]
        let metrics = [ "margin" : margin ]
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[view]-margin-|", options: [], metrics: metrics, views: views)
        superview?.addConstraints(constraints)
        return constraints
    }

    @discardableResult func alignParentLeft(margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: superview, attribute: .left, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    @discardableResult func alignParentRight(margin: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = superview else { return NSLayoutConstraint() }
        let constraint = NSLayoutConstraint(item: superview, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: margin)
        superview.addConstraint(constraint)
        return constraint
    }

    @discardableResult func alignParentTop(margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    @discardableResult func alignParentBottom(margin: CGFloat = 0) -> NSLayoutConstraint {
        guard let superview = superview else { return NSLayoutConstraint() }
        let constraint = NSLayoutConstraint(item: superview, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: margin)
        superview.addConstraint(constraint)
        return constraint
    }

    @discardableResult func centerParentHorizontal(offset: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: offset)
        superview?.addConstraint(constraint)
        return constraint
    }

    @discardableResult func centerParentVertical(offset: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1, constant: offset)
        superview?.addConstraint(constraint)
        return constraint
    }

    @discardableResult func toRightOf(_ view: UIView, margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    @discardableResult func toLeftOf(_ view: UIView, margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    @discardableResult func toTopOf(_ view: UIView, margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    @discardableResult func toBottomOf(_ view: UIView, margin: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: margin)
        superview?.addConstraint(constraint)
        return constraint
    }

    @discardableResult func setMinHeight(_ height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        addConstraint(constraint)
        return constraint
    }

    @discardableResult func setMaxHeight(_ height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        addConstraint(constraint)
        return constraint
    }

    @discardableResult func setHeightConstraint(_ height: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        addConstraint(constraint)
        return constraint
    }

    @discardableResult func setWidthConstraint(_ width: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
        addConstraint(constraint)
        return constraint
    }

    @discardableResult func setWidthConstraint(multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint {
        guard let superview = superview else { return NSLayoutConstraint() }
        let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: superview, attribute: .width, multiplier: multiplier, constant: constant)
        superview.addConstraint(constraint)
        return constraint
    }

}
