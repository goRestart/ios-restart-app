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
        let actualWidth = width / UIScreen.mainScreen().scale;
        let line = CALayer()
        line.frame = CGRect(x: 0, y: frame.height - actualWidth, width: frame.width, height: actualWidth)
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
