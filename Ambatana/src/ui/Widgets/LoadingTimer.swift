//
//  LoadingTimer.swift
//  LetGo
//
//  Created by Eli Kohen on 17/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

class LoadingTimer: UIView {

    enum AnimationType {
        case EmptyToFull, FullToEmpty
    }

    var loadingColor: UIColor = UIColor.whiteColor() {
        didSet {
            guard let loadingShape = loadingShape else { return }
            loadingShape.strokeColor = loadingColor.CGColor
        }
    }

    var animationType = AnimationType.FullToEmpty

    private var loadingShape: CAShapeLayer?
    private var completion: ((Bool)->Void)?

    private static let loadingMargin: CGFloat = 5
    private let animationName = "strokeEnd"

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayoutDependantUI()
    }

    deinit {
        stop()
    }

    func start(timeout: NSTimeInterval, completion: ((Bool)->Void)?) {
        stop()
        self.completion = completion
        startLoadingAnimation(timeout)
    }

    func stop() {
        loadingShape?.removeAnimationForKey(animationName)
        loadingShape?.strokeStart = 0
        loadingShape?.strokeEnd = 0
        loadingShape?.removeFromSuperlayer()
    }


    // MARK: - Private methods

    private func setupUI() {
        clipsToBounds = true
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
    }

    private func setupLayoutDependantUI() {
        layer.cornerRadius = height/2
        loadingShape?.bounds = CGRect(x: 0, y: 0,
                                      width: width - (LoadingTimer.loadingMargin*2),
                                      height: height - (LoadingTimer.loadingMargin*2))
        loadingShape?.position = CGPoint(x: width / 2, y: width / 2)
    }

    private func setupLoadingShape() {
        // Circle that we will animate
        let rectShape = CAShapeLayer()
        rectShape.bounds = CGRect(x: 0, y: 0, width: width - (LoadingTimer.loadingMargin*2), height: height - (LoadingTimer.loadingMargin*2))
        rectShape.position = CGPoint(x: width / 2, y: width / 2)
        rectShape.path = animationType.path(rectShape.bounds)
        rectShape.lineWidth = 2.5
        rectShape.strokeColor = loadingColor.CGColor
        rectShape.fillColor = UIColor.clearColor().CGColor
        rectShape.strokeStart = 0
        rectShape.transform = CATransform3DMakeRotation( 90.0 / 180.0 * CGFloat(-M_PI) , 0, 0, 1.0)
        rectShape.strokeEnd = animationType.initialStrokeEnd
        layer.addSublayer(rectShape)
        loadingShape = rectShape
    }

    private func startLoadingAnimation(duration: NSTimeInterval) {
        stop()
        setupLoadingShape()
        loadingShape?.strokeEnd = 1.0
        let stroke = CABasicAnimation(keyPath: "strokeEnd")
        stroke.delegate = self
        stroke.fromValue = animationType.strokeAnimStart
        stroke.toValue = animationType.strokeAnimEnd
        stroke.duration = duration
        loadingShape?.addAnimation(stroke, forKey: animationName)
    }


    // MARK: - CAAnimation Delegate (Just an extension of NSObject)

    dynamic override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        guard let propAnim = anim as? CAPropertyAnimation, let keyPath = propAnim.keyPath where keyPath == "strokeEnd"
            else { return }
        stop()
        completion?(flag)
    }
}


private extension LoadingTimer.AnimationType {
    func path(bounds: CGRect) -> CGPath {
        switch self {
        case .FullToEmpty:
            return UIBezierPath(ovalInRect: bounds).bezierPathByReversingPath().CGPath
        case .EmptyToFull:
            return UIBezierPath(ovalInRect: bounds).CGPath
        }
    }

    var initialStrokeEnd: CGFloat {
        switch self {
        case .FullToEmpty:
            return 1
        case .EmptyToFull:
            return 0
        }
    }

    var strokeAnimStart: CGFloat {
        return initialStrokeEnd
    }

    var strokeAnimEnd: CGFloat {
        switch self {
        case .FullToEmpty:
            return 0
        case .EmptyToFull:
            return 1
        }
    }
}
