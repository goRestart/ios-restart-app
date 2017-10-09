//
//  OvalLayer.swift
//  LetGo
//
//  Created by Facundo Menzella on 09/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

protocol OvalLayerDelegate: class {
    func ovalLayerExpandDidStop()
}

final class OvalLayer: CAShapeLayer, CAAnimationDelegate {
    private var ovalPathSmall: UIBezierPath { return UIBezierPath(ovalIn: CGRect(x: bounds.midX,
                                                                                 y: bounds.midY,
                                                                                 width: 0.0,
                                                                                 height: 0.0)) }
    private var ovalPathLarge: UIBezierPath {
        let side: CGFloat = 24.0
        let origin = (bounds.width - side) / 2.0
        return UIBezierPath(ovalIn: CGRect(x: origin,
                                           y: origin,
                                           width: side,
                                           height: side)) }
    weak var ovalDelegate: OvalLayerDelegate?

    override init(layer: Any) {
        super.init(layer: layer)
        fillColor = UIColor.clear.cgColor
        strokeColor = UIColor.white.cgColor
        lineWidth = 4.0

        path = ovalPathSmall.cgPath
    }

    override init() {
        super.init()
        fillColor = UIColor.clear.cgColor
        strokeColor = UIColor.white.cgColor
        lineWidth = 4.0

        path = ovalPathSmall.cgPath
    }

    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func expand() {
        compress()
        setNeedsDisplay()
        displayIfNeeded()
        guard let initialPath = path else {
            animateFromPath(ovalPathSmall.cgPath, toPath: ovalPathLarge.cgPath)
            return
        }
        animateFromPath(initialPath, toPath: ovalPathLarge.cgPath)
    }

    func compress() {
        path = ovalPathSmall.cgPath
    }

    private func animateFromPath(_ initialPath: CGPath?, toPath target: CGPath?) {
        let expandAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = initialPath
        expandAnimation.toValue = target
        expandAnimation.duration = 0.2
        expandAnimation.isRemovedOnCompletion = false

        expandAnimation.delegate = self
        add(expandAnimation, forKey: nil)

        path = target
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.ovalDelegate?.ovalLayerExpandDidStop()
        }
    }
}
