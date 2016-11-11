//
//  UIView+Border.swift
//  LetGo
//
//  Created by AHL on 17/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

extension UIView {
    
    func addTopBorderWithWidth(width: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.mainScreen().scale;
        let line = CALayer()
        line.frame = CGRect(x: 0, y: 0, width: frame.width, height: actualWidth)
        line.backgroundColor = color.CGColor
        layer.addSublayer(line)
        return line
    }

    func addBottomBorderWithWidth(width: CGFloat, color: UIColor) -> CALayer {
        return addBottomBorderWithWidth(width, xPosition: 0, color: color)
    }

    func addBottomBorderWithWidth(width: CGFloat, xPosition: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.mainScreen().scale;
        let line = CALayer()
        line.frame = CGRect(x: xPosition, y: frame.height - actualWidth, width: frame.width-xPosition, height: actualWidth)
        line.backgroundColor = color.CGColor
        layer.addSublayer(line)
        return line
    }

    func addRightBorderWithWidth(width: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.mainScreen().scale;
        let line = CALayer()
        line.frame = CGRect(x: frame.width - actualWidth, y: 0, width: actualWidth, height: frame.height)
        line.backgroundColor = color.CGColor
        layer.addSublayer(line)
        return line
    }
    
    func addLeftBorderWithWidth(width: CGFloat, color: UIColor) -> CALayer {
        let actualWidth = width / UIScreen.mainScreen().scale;
        let line = CALayer()
        line.frame = CGRect(x: 0, y: 0, width: actualWidth, height: frame.height)
        line.backgroundColor = color.CGColor
        layer.addSublayer(line)
        return line
    }
}


// MARK: - Shadows

extension UIView {
    func applyFloatingButtonShadow() {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        layer.shadowOpacity = 0.24
        layer.shadowRadius = 8.0
    }
    
    func applyDefaultShadow() {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.3
    }
    func applyInfoBubbleShadow() {
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowRadius = 15
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 8.0
    }
}


// MARK: - Rounded corners

extension UIView {
    func setRoundedCorners(roundingCorners: UIRectCorner, cornerRadius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners,
                                    cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.CGPath
        layer.mask = maskLayer
    }
}
