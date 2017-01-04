//
//  LoadingIndicator.swift
//  LetGo
//
//  Created by Eli Kohen on 16/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class LoadingIndicator: UIView {

    open var color: UIColor = UIColor.white {
        didSet {
            loadingShape.strokeColor = color.cgColor
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

    func stopAnimating(_ correctState: Bool, completion: (()->())? = nil) {
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

        rectShape.path = UIBezierPath(ovalIn: rectShape.bounds).cgPath
        rectShape.lineWidth = 3.0
        rectShape.strokeColor = color.cgColor
        rectShape.fillColor = UIColor.clear.cgColor
        rectShape.strokeStart = 0
        rectShape.strokeEnd = 0.1
        loadingShape = rectShape

        // ok/wrong icons
        okIcon = UIImageView(frame: bounds)
        addSubview(okIcon)
        setFillConstraintsTo(okIcon)
        okIcon.contentMode = UIViewContentMode.center
        okIcon.image = UIImage(named: "ic_post_ok")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        okIcon.alpha = 0
        okIcon.tintColor = color

        wrongIcon = UIImageView(frame: bounds)
        addSubview(wrongIcon)
        setFillConstraintsTo(wrongIcon)
        wrongIcon.contentMode = UIViewContentMode.center
        wrongIcon.image = UIImage(named: "ic_post_wrong")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
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
        animation.isCumulative = true
        animation.repeatCount = HUGE
        animation.toValue = 2 * M_PI
        loadingShape.add(animation, forKey: "rotation")
    }

    private func finishLoadingAnimation() {

        loadingShape.strokeEnd = 1.0
        let stroke = CABasicAnimation(keyPath: "strokeEnd")
        stroke.delegate = self
        stroke.fromValue = 0.1
        stroke.toValue = 1
        stroke.duration = 0.3
        loadingShape.add(stroke, forKey: "strokeEnd")
    }

    private func showImageAnimation(_ okMode: Bool) {
        let view = okMode ? okIcon : wrongIcon
        view?.alpha = 0
        UIView.animate(withDuration: 0.2,
            animations: {
                view?.alpha = 1
            },
            completion: { [weak self] (completed) -> Void in
                view?.alpha = 1
                if let completion = self?.endAnimationsCompletion {
                    completion()
                    self?.endAnimationsCompletion = nil
                }
            }
        )
    }

    private func setFillConstraintsTo(_ view: UIView){
        view.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal,
            toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1,
            constant: 0)
        let left = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal,
            toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.right,
            relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1,
            constant: 0)
        addConstraints([top, bottom, left, right])
    }
}


// MARK: - CAAnimationDelegate

extension LoadingIndicator: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let propAnim = anim as? CAPropertyAnimation, let keyPath = propAnim.keyPath, keyPath == "strokeEnd" {
            loadingShape.removeAnimation(forKey: "rotation")
            if let finalState = pendingFinalState {
                showImageAnimation(finalState)
            } else if let completion = endAnimationsCompletion {
                completion()
                endAnimationsCompletion = nil
            }
        }
    }
}
