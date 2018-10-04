import UIKit
import LGComponents

final class VPPostListingRedCamFooter: UIView {

    private struct FooterMetrics {
        static let galleryIconSide: CGFloat = 70
        static let cameraIconSide: CGFloat = 80
        static let newBadgeInsets: UIEdgeInsets = UIEdgeInsetsMake(4, 6, 4, 6)
    }

    let galleryButton: UIButton = UIButton()
    let photoButton: UIButton = UIButton()
    let videoButton: UIButton = UIButton()
    let newBadgeLabel: UILabel = {
        let label = UIRoundedLabelWithPadding()
        label.text = R.Strings.productPostCameraVideoModeButtonNewBadge
        label.backgroundColor = UIColor.Camera.cameraButton
        label.font = UIFont.systemBoldFont(size: 11)
        label.textColor = UIColor.white
        label.padding = FooterMetrics.newBadgeInsets
        return label
    }()
    let cameraButton: UIButton = CameraButton()
    let infoButton: UIButton = UIButton()
    let cameraTooltip: CameraTooltip = CameraTooltip()
    let doneButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.setTitle(R.Strings.commonDone, for: .normal)
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 30)
        return button
    }()
    private let infoButtonIncluded: Bool
    private var cameraButtonCenterXConstraint: NSLayoutConstraint?
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
        return [galleryButton, photoButton, videoButton, cameraButton, cameraTooltip, infoButton, doneButton].compactMap { $0 }.reduce(false) { (result, view) -> Bool in
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
        newBadgeLabel.alpha = scroll
        infoButton.alpha = scroll
        cameraTooltip.alpha = scroll
        cameraTooltip.alpha = scroll
        doneButton.alpha = scroll

        let rightOffset = cameraButton.frame.width/2 + Metrics.margin
        let movement = width/2 - rightOffset
        cameraButtonCenterXConstraint?.constant = movement * (1.0 - scroll)
    }

    func updateToPhotoMode() {
        guard let cameraButton = cameraButton as? CameraButton else { return }
        photoButton.setTitleColor(UIColor.Camera.selectedPhotoVideoButton, for: .normal)
        videoButton.setTitleColor(UIColor.Camera.unselectedPhotoVideoButton, for: .normal)
        cameraButton.mode = .Photo
        animate(view: recordingTooltip, toHidden: true, completion: nil)
    }

    func updateToVideoMode() {
        guard let cameraButton = cameraButton as? CameraButton else { return }
        photoButton.setTitleColor(UIColor.Camera.unselectedPhotoVideoButton, for: .normal)
        videoButton.setTitleColor(UIColor.Camera.selectedPhotoVideoButton, for: .normal)
        cameraButton.mode = .Video
    }

    func showTooltip(tooltipText: NSAttributedString?) {
        cameraTooltip.label.attributedText = tooltipText
        animate(view: cameraTooltip, toHidden: false, completion: nil)
    }

    func hideTooltip() {
        animate(view: cameraTooltip, toHidden: true, completion: nil)
    }

    func startRecording() {
        guard !isRecording, let cameraButton = cameraButton as? CameraButton else { return }
        isRecording = true
        cameraButton.startRecording()
        cameraTooltip.isHidden = true
    }

    func stopRecording() {
        guard isRecording, let cameraButton = cameraButton as? CameraButton else { return }
        isRecording = false
        cameraButton.stopRecording()
        recordingTooltip.isHidden = true
    }

    func updateVideoRecordingDurationProgress(progress: CGFloat, recordingDuration: TimeInterval) {

        guard progress > 0, isRecording else { return }
        guard let cameraButton = cameraButton as? CameraButton else { return }
        cameraButton.progress = progress

        recordingTooltip.label.text = String(format: "0:%02d", Int(floor(recordingDuration)))

        animate(view: cameraTooltip, toHidden: true, completion: nil)
        animate(view: recordingTooltip, toHidden: false, completion: nil)
    }

    private func animate(view: UIView, toHidden hidden: Bool, completion: ((Bool) -> Void)?) {
        guard hidden != view.isHidden else {
            completion?(false)
            return
        }
        let alpha: CGFloat = hidden ? 0.0 : 1.0
        view.isHidden = !hidden
        view.animateTo(alpha: alpha, duration: 0.3) { finished in
            view.isHidden = hidden
            completion?(finished)
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

        cameraTooltip.label.numberOfLines = 0
        cameraTooltip.label.textAlignment = .center

        recordingTooltip.label.font = UIFont.systemBoldFont(size: 21)
        recordingTooltip.label.textColor = UIColor.white

        addSubviewsForAutoLayout([galleryButton, doneButton, photoButton, videoButton, cameraButton, infoButton,
                                  cameraTooltip, recordingTooltip, newBadgeLabel])
    }

    func setupAccessibilityIds() {
        galleryButton.set(accessibilityId: .postingGalleryButton)
        cameraButton.set(accessibilityId: .postingCameraButton)
        infoButton.set(accessibilityId: .postingInfoButton)
        photoButton.set(accessibilityId: .postingPhotoButton)
        videoButton.set(accessibilityId: .postingVideoButton)
        doneButton.set(accessibilityId: .postingDoneButton)
    }

    func setupLayout() {
        infoButton.layout(with: self)
            .trailing()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom()
        infoButton.layout()
            .width(FooterMetrics.galleryIconSide)
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

        newBadgeLabel.layout(with: videoButton)
            .trailing(to: .leading, by: -Metrics.veryShortMargin)
            .centerY()

        cameraButton.layout(with: self)
            .centerX(constraintBlock: { [weak self] constraint in self?.cameraButtonCenterXConstraint = constraint })
            .top()
            .bottom(by: -(Metrics.margin + 60))
        cameraButton.layout().width(FooterMetrics.cameraIconSide).widthProportionalToHeight()

        doneButton.layout(with: self)
            .trailing(by: -Metrics.margin)
        doneButton.layout(with: cameraButton)
            .centerY()
        doneButton.layout()
            .height(44.0)

        infoButton.isHidden = !infoButtonIncluded

        cameraTooltip.isHidden = true
        cameraTooltip.layout(with: cameraButton).above(by: -27).centerX()
        cameraTooltip.layout(with: self).leading(by: Metrics.margin, relatedBy: .greaterThanOrEqual)

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
