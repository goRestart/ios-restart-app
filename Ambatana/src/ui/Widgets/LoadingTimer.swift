//
//  LoadingTimer.swift
//  LetGo
//
//  Created by Eli Kohen on 17/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

class LoadingTimer: UIView {

    var loadingColor: UIColor = UIColor.whiteColor() {
        didSet {
            guard let loadingShape = loadingShape else { return }
            loadingShape.strokeColor = loadingColor.CGColor
        }
    }

    private var loadingShape: CAShapeLayer?
    private var completion: (()->Void)?

    private static let loadingMargin: CGFloat = 8
    private let animationName = "strokeEnd"

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    deinit {
        stop()
    }

    func start(timeout: NSTimeInterval, completion: (()->Void)?) {
        stop()
        self.completion = completion
        startLoadingAnimation(timeout)
    }

    func stop() {
        loadingShape?.removeAnimationForKey(animationName)
        loadingShape?.strokeStart = 0
        loadingShape?.strokeEnd = 0
    }


    // MARK: - Private methods

    private func setupUI() {
        clipsToBounds = true
        layer.cornerRadius = height/2
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)

        // Circle that we will animate
        let rectShape = CAShapeLayer()
        rectShape.bounds = CGRect(x: 0, y: 0,
                                  width: width - (LoadingTimer.loadingMargin*2),
                                  height: height - (LoadingTimer.loadingMargin*2))
        rectShape.position = CGPoint(x: width / 2, y: width / 2)
        layer.addSublayer(rectShape)

        rectShape.path = UIBezierPath(ovalInRect: rectShape.bounds).CGPath
        rectShape.lineWidth = 3.0
        rectShape.strokeColor = loadingColor.CGColor
        rectShape.fillColor = UIColor.clearColor().CGColor
        rectShape.strokeStart = 0
        rectShape.strokeEnd = 0
        loadingShape = rectShape
    }

    private func startLoadingAnimation(duration: NSTimeInterval) {
        stop()
        loadingShape?.strokeEnd = 1.0
        let stroke = CABasicAnimation(keyPath: "strokeEnd")
        stroke.delegate = self
        stroke.fromValue = 0
        stroke.toValue = 1
        stroke.duration = duration
        loadingShape?.addAnimation(stroke, forKey: animationName)
    }


    // MARK: - CAAnimation Delegate (Just an extension of NSObject)

    dynamic override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        guard let propAnim = anim as? CAPropertyAnimation, let keyPath = propAnim.keyPath where keyPath == "strokeEnd"
            else { return }
        completion?()
    }
}
