//
//  UIView+Border.swift
//  LetGo
//
//  Created by AHL on 17/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

extension UIView {
    
    @discardableResult 
    func addTopBorderWithWidth(_ width: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.main.scale;
        let line = CALayer()
        line.frame = CGRect(x: 0, y: 0, width: frame.width, height: actualWidth)
        line.backgroundColor = color.cgColor
        layer.addSublayer(line)
        return line
    }

    @discardableResult
    func addBottomBorderWithWidth(_ width: CGFloat, color: UIColor) -> CALayer {
        return addBottomBorderWithWidth(width, xPosition: 0, color: color)
    }

    @discardableResult
    func addBottomBorderWithWidth(_ width: CGFloat, xPosition: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.main.scale;
        let line = CALayer()
        line.frame = CGRect(x: xPosition, y: frame.height - actualWidth, width: frame.width-xPosition, height: actualWidth)
        line.backgroundColor = color.cgColor
        layer.addSublayer(line)
        return line
    }

    @discardableResult
    func addRightBorderWithWidth(_ width: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.main.scale;
        let line = CALayer()
        line.frame = CGRect(x: frame.width - actualWidth, y: 0, width: actualWidth, height: frame.height)
        line.backgroundColor = color.cgColor
        layer.addSublayer(line)
        return line
    }
    
    @discardableResult
    func addLeftBorderWithWidth(_ width: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.main.scale;
        let line = CALayer()
        line.frame = CGRect(x: 0, y: 0, width: actualWidth, height: frame.height)
        line.backgroundColor = color.cgColor
        layer.addSublayer(line)
        return line
    }

    @discardableResult
    func addTopViewBorderWith(width: CGFloat, color: UIColor) -> UIView {
        let topSeparator = UIView()
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topSeparator)
        topSeparator.fitHorizontallyToParent()
        topSeparator.alignParentTop()
        topSeparator.backgroundColor = color
        topSeparator.setHeightConstraint(width)
        return topSeparator
    }

    @discardableResult
    func addBottomViewBorderWith(width: CGFloat, color: UIColor, leftMargin: CGFloat = 0, rightMargin: CGFloat = 0) -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        separator.alignParentLeft(margin: leftMargin)
        separator.alignParentRight(margin: rightMargin)
        separator.alignParentBottom()
        separator.backgroundColor = color
        separator.setHeightConstraint(width)
        return separator
    }
}


// MARK: - Shadows

extension UIView {
    func applyFloatingButtonShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        layer.shadowOpacity = 0.24
        layer.shadowRadius = 8.0
    }
    
    func applyDefaultShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3
    }
    func applyInfoBubbleShadow() {
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 15
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 8.0
    }
}


// MARK: - Rounded corners

extension UIView {
    func setRoundedCorners(_ roundingCorners: UIRectCorner, cornerRadius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
