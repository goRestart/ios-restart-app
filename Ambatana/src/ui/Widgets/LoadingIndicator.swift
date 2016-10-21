//
//  LoadingIndicator.swift
//  LetGo
//
//  Created by Eli Kohen on 16/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

public class LoadingIndicator: UIView {

    public var color: UIColor = UIColor.whiteColor() {
        didSet {
            loadingShape.strokeColor = color.CGColor
            okIcon.tintColor = color
            wrongIcon.tintColor = color
        }
    }

    private var loadingShape: CAShapeLayer!
    private var okIcon: UIImageView!
    private var wrongIcon: UIImageView!

    private var pendingFinalState: Bool?
    private var endAnimationsCompletion: (()->())?

    // MARK: - View Lifecycle

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }


    // MARK: - Public methods

    func startAnimating() {
        startLoadingAnimation()
    }

    func stopAnimating(correctState: Bool, completion: (()->())? = nil) {
        pendingFinalState = correctState
        endAnimationsCompletion = completion
        finishLoadingAnimation()
    }


    // MARK: - Private methods

    private func setupView() {
        layoutIfNeeded()
        // Circle that we will animate
        let rectShape = CAShapeLayer()
        rectShape.bounds = bounds
        rectShape.position = CGPoint(x: width / 2, y: width / 2)
        layer.addSublayer(rectShape)

        rectShape.path = UIBezierPath(ovalInRect: rectShape.bounds).CGPath
        rectShape.lineWidth = 3.0
        rectShape.strokeColor = color.CGColor
        rectShape.fillColor = UIColor.clearColor().CGColor
        rectShape.strokeStart = 0
        rectShape.strokeEnd = 0.1
        loadingShape = rectShape

        // ok/wrong icons
        okIcon = UIImageView(frame: bounds)
        addSubview(okIcon)
        setFillConstraintsTo(okIcon)
        okIcon.contentMode = UIViewContentMode.Center
        okIcon.image = UIImage(named: "ic_post_ok")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        okIcon.alpha = 0
        okIcon.tintColor = color

        wrongIcon = UIImageView(frame: bounds)
        addSubview(wrongIcon)
        setFillConstraintsTo(wrongIcon)
        wrongIcon.contentMode = UIViewContentMode.Center
        wrongIcon.image = UIImage(named: "ic_post_wrong")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        wrongIcon.alpha = 0
        wrongIcon.tintColor = color
    }

    private func startLoadingAnimation() {

        okIcon.alpha = 0
        wrongIcon.alpha = 0
        loadingShape.strokeEnd = 0.1

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.delegate = self
        animation.duration = 1
        animation.cumulative = true
        animation.repeatCount = HUGE
        animation.toValue = 2 * M_PI
        loadingShape.addAnimation(animation, forKey: "rotation")
    }

    private func finishLoadingAnimation() {

        loadingShape.strokeEnd = 1.0
        let stroke = CABasicAnimation(keyPath: "strokeEnd")
        stroke.delegate = self
        stroke.fromValue = 0.1
        stroke.toValue = 1
        stroke.duration = 0.3
        loadingShape.addAnimation(stroke, forKey: "strokeEnd")
    }

    private func showImageAnimation(okMode: Bool) {
        let view = okMode ? okIcon : wrongIcon
        view.alpha = 0
        UIView.animateWithDuration(0.2,
            animations: {
                view.alpha = 1
            },
            completion: { [weak self] (completed) -> Void in
                view.alpha = 1
                if let completion = self?.endAnimationsCompletion {
                    completion()
                    self?.endAnimationsCompletion = nil
                }
            }
        )
    }

    private func setFillConstraintsTo(view: UIView){
        view.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal,
            toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1,
            constant: 0)
        let left = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal,
            toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1,
            constant: 0)
        addConstraints([top, bottom, left, right])
    }
}


// MARK: - CAAnimationDelegate

extension LoadingIndicator: CAAnimationDelegate {
    public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let propAnim = anim as? CAPropertyAnimation, keyPath = propAnim.keyPath where keyPath == "strokeEnd" {
            loadingShape.removeAnimationForKey("rotation")
            if let finalState = pendingFinalState {
                showImageAnimation(finalState)
            } else if let completion = endAnimationsCompletion {
                completion()
                endAnimationsCompletion = nil
            }
        }
    }
}
