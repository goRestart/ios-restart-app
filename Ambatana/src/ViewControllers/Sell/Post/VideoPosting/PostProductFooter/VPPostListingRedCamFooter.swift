import UIKit
import LGComponents

final class VPPostListingRedCamFooter: UIView {
    static let galleryIconSide: CGFloat = 70
    static let cameraIconSide: CGFloat = 80

    let galleryButton: UIButton = UIButton()
    let photoButton: UIButton = UIButton()
    let videoButton: UIButton = UIButton()
    let cameraButton: UIButton = CameraButton()
    let infoButton: UIButton = UIButton()
    private let infoButtonIncluded: Bool
    private var cameraButtonCenterXConstraint: NSLayoutConstraint?
    private var recordVideoHintLabel = CameraTooltip()
    private var recordingTooltip = RecordingTooltip()
    private var isRecording: Bool = false


    // MARK: - Lifecycle

    init(infoButtonIncluded: Bool) {
        self.infoButtonIncluded = infoButtonIncluded
        super.init(frame: CGRect.zero)

        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Overrides

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return [galleryButton, photoButton, videoButton, cameraButton, infoButton].flatMap { $0 }.reduce(false) { (result, view) -> Bool in
            let convertedPoint = view.convert(point, from: self)
            return result || (!view.isHidden && view.point(inside: convertedPoint, with: event))
        }
    }
}


// MARK: - PostListingFooter

extension VPPostListingRedCamFooter: PostListingFooter {

    func update(scroll: CGFloat) {
        galleryButton.alpha = scroll
        photoButton.alpha = scroll
        videoButton.alpha = scroll
        infoButton.alpha = scroll
        recordVideoHintLabel.alpha = scroll

        let rightOffset = cameraButton.frame.width/2 + Metrics.margin
        let movement = width/2 - rightOffset
        cameraButtonCenterXConstraint?.constant = movement * (1.0 - scroll)
    }

    func updateToPhotoMode() {
        guard let cameraButton = cameraButton as? CameraButton else { return }
        photoButton.setTitleColor(UIColor.Camera.selectedPhotoVideoButton, for: .normal)
        videoButton.setTitleColor(UIColor.Camera.unselectedPhotoVideoButton, for: .normal)
        cameraButton.mode = .Photo
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.recordVideoHintLabel.alpha = 0
            self?.recordingTooltip.alpha = 0
        }) { [weak self] (finished) in
            self?.recordVideoHintLabel.isHidden = true
            self?.recordingTooltip.isHidden = true
        }
    }

    func updateToVideoMode() {
        guard let cameraButton = cameraButton as? CameraButton else { return }
        photoButton.setTitleColor(UIColor.Camera.unselectedPhotoVideoButton, for: .normal)
        videoButton.setTitleColor(UIColor.Camera.selectedPhotoVideoButton, for: .normal)
        cameraButton.mode = .Video
        recordVideoHintLabel.alpha = 0
        recordVideoHintLabel.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseIn, animations: { [weak self] in
            self?.recordVideoHintLabel.alpha = 1
        }, completion: nil)
    }

    func startRecording() {
        guard !isRecording, let cameraButton = cameraButton as? CameraButton else { return }
        isRecording = true
        cameraButton.startRecording()
        recordVideoHintLabel.isHidden = true
    }

    func stopRecording() {
        guard isRecording, let cameraButton = cameraButton as? CameraButton else { return }
        isRecording = false
        cameraButton.stopRecording()
        recordingTooltip.isHidden = true
    }

    func updateVideoRecordingDurationProgress(progress: CGFloat, remainingTime: TimeInterval) {

        guard progress > 0, isRecording else { return }
        guard let cameraButton = cameraButton as? CameraButton else { return }
        cameraButton.progress = progress

        recordingTooltip.label.text = String(format: "0:%02d", Int(ceil(remainingTime)))

        if recordingTooltip.isHidden {
            recordingTooltip.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.recordVideoHintLabel.alpha = 0
                self?.recordingTooltip.alpha = 1
            }) { [weak self] (finished) in
                self?.recordVideoHintLabel.isHidden = true
            }
        }
    }
}


// MARK: - Private methods

fileprivate extension VPPostListingRedCamFooter {
    func setupUI() {

        galleryButton.setTitleColor(UIColor.white, for: .normal)
        galleryButton.setTitle(R.Strings.productPostCameraGalleryTextButton, for: .normal)
        galleryButton.titleLabel?.font = UIFont.systemBoldFont(size: 17)
        galleryButton.applyShadow(withOpacity: 0.7, radius: 1)

        photoButton.setTitleColor(UIColor.white, for: .normal)
        photoButton.setTitle(R.Strings.productPostCameraPhotoModeButton, for: .normal)
        photoButton.titleLabel?.font = UIFont.systemBoldFont(size: 17)
        photoButton.applyShadow(withOpacity: 0.7, radius: 1)
        photoButton.setTitleColor(UIColor.Camera.selectedPhotoVideoButton, for: .normal)

        videoButton.setTitleColor(UIColor.white, for: .normal)
        videoButton.setTitle(R.Strings.productPostCameraVideoModeButton, for: .normal)
        videoButton.titleLabel?.font = UIFont.systemBoldFont(size: 17)
        videoButton.applyShadow(withOpacity: 0.7, radius: 1)
        videoButton.setTitleColor(UIColor.Camera.unselectedPhotoVideoButton, for: .normal)

        infoButton.setImage(R.Asset.IconsButtons.info.image, for: .normal)

        let highlightedText = R.Strings.productPostCameraVideoRecordingTooltipHighlightedWord
        let hintText = R.Strings.productPostCameraVideoRecordingTooltip(highlightedText)
        let hintNSString = NSString(string: hintText)
        let range = hintNSString.range(of: highlightedText)
        let attributues: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),
                                                          NSAttributedStringKey.foregroundColor: UIColor.white]
        let hint = NSMutableAttributedString(string: hintText, attributes: attributues)

        if range.location != NSNotFound {
            hint.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.primaryColor, range: range)
        }

        recordVideoHintLabel.label.attributedText = hint
        recordVideoHintLabel.label.numberOfLines = 0
        recordVideoHintLabel.label.textAlignment = .center

        recordingTooltip.label.font = UIFont.systemBoldFont(size: 21)
        recordingTooltip.label.textColor = UIColor.white

        addSubviewsForAutoLayout([galleryButton, photoButton, videoButton, cameraButton, infoButton, recordVideoHintLabel, recordingTooltip])
    }

    func setupAccessibilityIds() {
        galleryButton.set(accessibilityId: .postingGalleryButton)
        cameraButton.set(accessibilityId: .postingCameraButton)
        infoButton.set(accessibilityId: .postingInfoButton)
        photoButton.set(accessibilityId: .postingPhotoButton)
        videoButton.set(accessibilityId: .postingVideoButton)
    }

    func setupLayout() {
        infoButton.layout(with: self)
            .trailing()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom()
        infoButton.layout()
            .width(VPPostListingRedCamFooter.galleryIconSide)
            .widthProportionalToHeight()

        galleryButton.layout(with: self)
            .leading(by: Metrics.margin)
            .top(relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.margin)

        photoButton.layout(with: self)
            .centerX()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.margin)

        videoButton.layout(with: self)
            .trailing(by: -Metrics.margin)
            .top(relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.margin)

        cameraButton.layout(with: self)
            .centerX(constraintBlock: { [weak self] constraint in self?.cameraButtonCenterXConstraint = constraint })
            .top(relatedBy: .greaterThanOrEqual)
            .bottom(by: -(Metrics.margin + 60))
        cameraButton.layout().width(VPPostListingRedCamFooter.cameraIconSide).widthProportionalToHeight()

        infoButton.isHidden = !infoButtonIncluded

        recordVideoHintLabel.isHidden = true
        recordVideoHintLabel.layout(with: cameraButton).above(by: -27).centerX()
        recordVideoHintLabel.layout(with: self).leading(by: Metrics.margin, relatedBy: .greaterThanOrEqual)

        recordingTooltip.isHidden = true
        recordingTooltip.layout(with: cameraButton).above(by: -50).centerX()
        recordingTooltip.layout(with: self).leading(by: Metrics.margin, relatedBy: .greaterThanOrEqual)
    }
}

final class CameraButton: UIButton {

    enum CameraButtonMode {
        case Photo
        case Video
    }

    var mode: CameraButtonMode = .Photo {
        didSet {
            updateCameraMode(cameraMode: mode)
        }
    }

    var progress: CGFloat {
        get { return videoRecordingProgressLayer.progress }
        set { videoRecordingProgressLayer.progress = newValue }
    }

    private static let buttonSize: CGSize = CGSize(width: 80, height: 80)
    private static let strokeWidth: CGFloat = 4

    private var backgroundLayer: CALayer = CALayer()

    private var iconsLayer: CameraButtonIconsLayer = {
        let width = buttonSize.width - 2 * strokeWidth
        let layer = CameraButtonIconsLayer(size: CGSize(width: width, height: width))
        return layer
    }()

    private var videoRecordingProgressLayer: VideoRecordingProgressLayer = {
        let layer = VideoRecordingProgressLayer(size: CGSize(width: 150, height: 150))
        layer.progress = 0.25
        return layer
    }()

    private var videoRecordingLayer: VideoRecordingLayer = {
        let layer = VideoRecordingLayer(outerCircleSize: CGSize(width: 150, height: 150), innerCircleSize: CGSize(width: 60, height: 60))
        return layer
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: CGRect(origin: .zero, size: CameraButton.buttonSize))

        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }

    override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set {
            super.isHighlighted = newValue
            if newValue {
                backgroundLayer.backgroundColor = UIColor.Camera.cameraButtonHighlighted.cgColor
            } else {
                backgroundLayer.backgroundColor = UIColor.Camera.cameraButton.cgColor
            }
        }
    }

    func startRecording() {
        iconsLayer.isHidden = true
        backgroundLayer.isHidden = true
        videoRecordingLayer.isHidden = false
        videoRecordingLayer.startRecording()
        videoRecordingProgressLayer.progress = 0
        videoRecordingProgressLayer.isHidden = false
    }

    func stopRecording() {
        iconsLayer.isHidden = false
        backgroundLayer.isHidden = false
        videoRecordingLayer.isHidden = true
        videoRecordingLayer.stopRecording()
        videoRecordingProgressLayer.isHidden = true
        videoRecordingProgressLayer.progress = 0
    }

    private func updateCameraMode(cameraMode: CameraButtonMode) {
        if cameraMode == .Photo {
            iconsLayer.showCamera()
        } else {
            iconsLayer.showVideo()
        }
    }

    private func setupUI() {
        backgroundLayer.frame = bounds
        backgroundLayer.backgroundColor = UIColor.Camera.cameraButton.cgColor
        backgroundLayer.cornerRadius = bounds.width / 2
        backgroundLayer.borderWidth = CameraButton.strokeWidth
        backgroundLayer.borderColor = UIColor.white.cgColor
        backgroundLayer.shadowOpacity = 0.75
        backgroundLayer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundLayer.shadowRadius = 3

        iconsLayer.frame = CGRect(origin: center, size: iconsLayer.bounds.size)
        iconsLayer.showCamera()

        videoRecordingLayer.position = center
        videoRecordingLayer.isHidden = true

        videoRecordingProgressLayer.position = center
        videoRecordingProgressLayer.isHidden = true

        layer.addSublayer(videoRecordingLayer)
        layer.addSublayer(videoRecordingProgressLayer)
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(iconsLayer)
    }

    private func setupAccessibilityIds() {
    }

    private func setupLayout() {
    }

    class CameraButtonIconsLayer: CALayer {

        static let animationDuration: TimeInterval = 0.5

        private var photoImageLayer: CALayer = {
            let layer = CALayer()
            layer.contents = R.Asset.IconsButtons.icPostTakePhotoIcon.image.cgImage
            layer.contentsGravity = kCAGravityCenter
            layer.contentsScale = UIScreen.main.scale
            return layer
        }()

        private var videoImageLayer: CALayer = {
            let layer = CALayer()
            layer.contents = R.Asset.IconsButtons.icPostRecordVideoIcon.image.cgImage
            layer.contentsGravity = kCAGravityCenter
            layer.contentsScale = UIScreen.main.scale
            return layer
        }()

        var hiddenPhotoPosition: CGPoint {
            return CGPoint(x: -bounds.width, y: 0)
        }

        var hiddenVideoPosition: CGPoint {
            return CGPoint(x: bounds.width, y: 0)
        }

        init(size: CGSize) {
            super.init()
            bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let maskLayer = CAShapeLayer()
            let bezier = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
            maskLayer.path = bezier.cgPath
            maskLayer.fillColor = UIColor.white.cgColor
            maskLayer.fillRule = kCAFillRuleNonZero
            maskLayer.bounds = bounds
            self.mask = maskLayer

            addSublayer(photoImageLayer)
            addSublayer(videoImageLayer)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public func showCamera() {
            CameraButtonIconsLayer.animate(layer: photoImageLayer, to: .zero, opacity: 1)
            CameraButtonIconsLayer.animate(layer: videoImageLayer, to: hiddenVideoPosition, opacity: 0)
        }

        public func showVideo() {
            CameraButtonIconsLayer.animate(layer: videoImageLayer, to: .zero, opacity: 1)
            CameraButtonIconsLayer.animate(layer: photoImageLayer, to: hiddenPhotoPosition, opacity: 0)
        }

        static func animate(layer: CALayer, to position: CGPoint, opacity: Float) {
            let currentPosition = layer.position
            layer.position = position
            let positionAnimation = CABasicAnimation(keyPath: "position.x")
            positionAnimation.fromValue = NSNumber(value: Int(currentPosition.x))

            let currentOpacity = layer.opacity
            layer.opacity = opacity
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = NSNumber(value: currentOpacity)

            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [positionAnimation, opacityAnimation]
            animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animationGroup.duration = animationDuration
            layer.add(animationGroup, forKey: "animationGroup")
        }
    }

    class VideoRecordingLayer: CALayer {

        private let innerCircleLayer = CAShapeLayer()
        private let outerCircleLayer = CAShapeLayer()
        private let innerCircleSize: CGSize
        private let outerCircleSize: CGSize

        init(outerCircleSize: CGSize, innerCircleSize: CGSize) {
            self.innerCircleSize = innerCircleSize
            self.outerCircleSize = outerCircleSize
            super.init()

            innerCircleLayer.path = UIBezierPath(ovalIn: CGRect.centeredFrameWithSize(size: innerCircleSize)).cgPath
            innerCircleLayer.fillColor = UIColor.white.cgColor

            outerCircleLayer.path = UIBezierPath(ovalIn: CGRect.centeredFrameWithSize(size: innerCircleSize)).cgPath
            outerCircleLayer.fillColor = UIColor.white.withAlphaComponent(0.7).cgColor

            addSublayer(outerCircleLayer)
            addSublayer(innerCircleLayer)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func startRecording() {
            let animation = CABasicAnimation(keyPath: "path")
            animation.toValue = UIBezierPath(ovalIn: CGRect.centeredFrameWithSize(size: outerCircleSize)).cgPath
            animation.duration = 0.25
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.fillMode = kCAFillModeBoth
            animation.isRemovedOnCompletion = false
            outerCircleLayer.add(animation, forKey: animation.keyPath)
        }

        func stopRecording() {
            outerCircleLayer.path = UIBezierPath(ovalIn: CGRect.centeredFrameWithSize(size: innerCircleSize)).cgPath
        }
    }

    class VideoRecordingProgressLayer: CALayer {
        var progress: CGFloat {
            get { return progressLayer.strokeEnd }
            set {
                if (newValue > 1.0) {
                    progressLayer.strokeEnd = 1.0
                } else if (newValue < 0.0) {
                    progressLayer.strokeEnd = 0.0
                } else {
                    progressLayer.strokeEnd = newValue
                }
            }
        }
        private let progressLayer = CAShapeLayer()
        private let progressPathLayer = CAShapeLayer()

        init(size: CGSize) {
            super.init()
            bounds = CGRect(origin: .zero, size: size)
            addSublayer(progressPathLayer)
            addSublayer(progressLayer)

            progressLayer.path = UIBezierPath(ovalIn: bounds).cgPath
            progressLayer.lineWidth = 4
            progressLayer.strokeColor = UIColor.Camera.cameraButton.cgColor
            progressLayer.fillColor = UIColor.clear.cgColor
            progressLayer.transform = CATransform3DMakeRotation(-CGFloat(90.0 / 180.0 * .pi), 0.0, 0.0, 1.0)
            progressLayer.frame = bounds

            progressPathLayer.path = UIBezierPath(ovalIn: bounds).cgPath
            progressPathLayer.lineWidth = 4
            progressPathLayer.strokeColor = UIColor.white.cgColor
            progressPathLayer.fillColor = UIColor.clear.cgColor
            progressPathLayer.frame = bounds
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

final class CameraTooltip: UIView {

    let label: UILabel = UILabel()
    private let bubbleLayer: CAShapeLayer = CAShapeLayer()
    private let bubbleCornerRadius: CGFloat = 10
    private let arrowSize = CGSize(width: 24, height: 10)

    init() {
        super.init(frame: .zero)

        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleLayer.path = UIBezierPath.bubblePath(for: bounds.size,
                                                   arrowSize: arrowSize,
                                                   cornerRadius: bubbleCornerRadius).cgPath
    }

    private func setupUI() {
        bubbleLayer.fillColor = UIColor(white: 44/255, alpha: 0.95).cgColor
        bubbleLayer.shadowColor = UIColor.black.cgColor
        bubbleLayer.shadowRadius = 4
        bubbleLayer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleLayer.shadowOpacity = 0.5
        bubbleLayer.path = UIBezierPath.bubblePath(for: bounds.size,
                                                   arrowSize: arrowSize,
                                                   cornerRadius: bubbleCornerRadius).cgPath

        layer.addSublayer(bubbleLayer)

        addSubviewForAutoLayout(label)
    }

    private func setupAccessibilityIds() {

    }

    private func setupLayout() {
        label.layout(with: self)
            .top(by: Metrics.margin)
            .left(by: Metrics.bigMargin)
            .bottom(by: -(Metrics.margin + arrowSize.height))
            .right(by: -Metrics.bigMargin)
    }
}

final class RecordingTooltip: UIView {

    let label: UILabel = UILabel()
    let recordingIcon: RecordingIcon = RecordingIcon()
    private let bubbleLayer: CAShapeLayer = CAShapeLayer()
    private let bubbleCornerRadius: CGFloat = 10
    private let arrowSize = CGSize(width: 24, height: 10)

    init() {
        super.init(frame: .zero)

        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleLayer.path = UIBezierPath.bubblePath(for: bounds.size,
                                                   arrowSize: arrowSize,
                                                   cornerRadius: bubbleCornerRadius).cgPath
    }

    override var isHidden: Bool {
        didSet {
            if !isHidden {
                recordingIcon.startAnimating()
            } else {
                recordingIcon.stopAnimating()
            }
        }
    }


    private func setupUI() {

        layer.addSublayer(bubbleLayer)

        bubbleLayer.fillColor = UIColor(white: 44/255, alpha: 0.95).cgColor
        bubbleLayer.shadowColor = UIColor.black.cgColor
        bubbleLayer.shadowRadius = 4
        bubbleLayer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleLayer.shadowOpacity = 0.5
        bubbleLayer.path = UIBezierPath.bubblePath(for: bounds.size,
                                                   arrowSize: arrowSize,
                                                   cornerRadius: bubbleCornerRadius).cgPath

        recordingIcon.backgroundColor = UIColor.Camera.cameraButton

        addSubviewsForAutoLayout([label, recordingIcon])
    }

    private func setupAccessibilityIds() {

    }

    private func setupLayout() {

        recordingIcon.layout(with: self)
            .leading(by: 9)

        label.layout(with: self)
            .top(by: 7)
            .bottom(by: -(7 + arrowSize.height))
            .trailing(by: -Metrics.shortMargin)

        label.layout(with: recordingIcon)
            .leading(to: .trailing , by: 6)
            .centerY()
    }

    final class RecordingIcon: UIView {

        static let size = CGSize(width: 12, height: 12)

        init() {
            super.init(frame: CGRect(origin: .zero, size: RecordingIcon.size))
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            layer.cornerRadius = width/2
        }

        override var intrinsicContentSize: CGSize {
            return RecordingIcon.size
        }

        func startAnimating() {
            alpha = 1
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse, .repeat], animations: { [weak self] in
                self?.alpha = 0
            }, completion: nil)
        }

        func stopAnimating() {
            layer.removeAllAnimations()
            alpha = 1
        }
    }
}

private extension UIBezierPath {

    static func bubblePath(for contentSize: CGSize, arrowSize: CGSize, cornerRadius: CGFloat) -> UIBezierPath {

        let topLeftCorner = CGPoint(x: 0, y: 0)
        let topRightCorner = CGPoint(x: contentSize.width, y: 0)
        let bottomRightCorner = CGPoint(x: contentSize.width, y: contentSize.height - arrowSize.height)
        let bottomLeftCorner = CGPoint(x: 0, y: contentSize.height - arrowSize.height)
        let rigthArrowCorner = CGPoint(x: contentSize.width / 2 + arrowSize.width / 2, y: bottomRightCorner.y)
        let bottomArrowCorner = CGPoint(x: contentSize.width / 2, y: contentSize.height)
        let leftArrowCorner = CGPoint(x: contentSize.width / 2 - arrowSize.width / 2, y: bottomRightCorner.y)

        let arrowBaseCurveControlPointDistance: CGFloat = arrowSize.width / 3
        let arrowTopCurveControlPointDistance: CGFloat = arrowBaseCurveControlPointDistance / 2

        let bezierPath = UIBezierPath()

        // Top left corner
        bezierPath.move(to: CGPoint(x: topLeftCorner.x, y: cornerRadius))
        bezierPath.addQuadCurve(to: CGPoint(x: topLeftCorner.x + cornerRadius, y: topLeftCorner.y),
                                controlPoint: topLeftCorner)
        // Top right corner
        bezierPath.addLine(to: CGPoint(x: topRightCorner.x - cornerRadius, y: topRightCorner.y))
        bezierPath.addQuadCurve(to: CGPoint(x: topRightCorner.x, y: topRightCorner.y + cornerRadius),
                                controlPoint: topRightCorner)
        // Bottom right corner
        bezierPath.addLine(to: CGPoint(x: bottomRightCorner.x, y: bottomRightCorner.y - cornerRadius))
        bezierPath.addQuadCurve(to: CGPoint(x: bottomRightCorner.x - cornerRadius, y: bottomRightCorner.y),
                                controlPoint: bottomRightCorner)
        // Arrow
        bezierPath.addCurve(to: rigthArrowCorner,
                            controlPoint1: bottomRightCorner,
                            controlPoint2: CGPoint(x: rigthArrowCorner.x + arrowBaseCurveControlPointDistance, y: rigthArrowCorner.y))
        bezierPath.addCurve(to: bottomArrowCorner,
                            controlPoint1: CGPoint(x: rigthArrowCorner.x - arrowBaseCurveControlPointDistance, y: rigthArrowCorner.y),
                            controlPoint2: CGPoint(x: bottomArrowCorner.x + arrowTopCurveControlPointDistance, y: bottomArrowCorner.y))
        bezierPath.addCurve(to: leftArrowCorner,
                            controlPoint1: CGPoint(x: bottomArrowCorner.x - arrowTopCurveControlPointDistance, y: bottomArrowCorner.y),
                            controlPoint2: CGPoint(x: leftArrowCorner.x + arrowBaseCurveControlPointDistance, y: leftArrowCorner.y))
        bezierPath.addCurve(to: CGPoint(x: bottomLeftCorner.x + cornerRadius, y: bottomLeftCorner.y),
                            controlPoint1: CGPoint(x: leftArrowCorner.x - arrowBaseCurveControlPointDistance, y: leftArrowCorner.y),
                            controlPoint2: bottomLeftCorner)
        // Bottom left corner
        bezierPath.addQuadCurve(to: CGPoint(x: bottomLeftCorner.x, y: bottomLeftCorner.y - cornerRadius),
                                controlPoint: bottomLeftCorner)
        bezierPath.close()

        return bezierPath
    }
}

extension CGRect {

    static func centeredFrameWithSize(size: CGSize) -> CGRect {
        let origin = CGPoint(x: -(size.width / 2), y: -(size.height / 2))
        return CGRect(origin: origin, size: size)
    }
}
