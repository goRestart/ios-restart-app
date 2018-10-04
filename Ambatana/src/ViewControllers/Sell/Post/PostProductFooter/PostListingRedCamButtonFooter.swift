import UIKit
import LGComponents

final class PostListingRedCamButtonFooter: UIView {

    private enum Layout {
        static let galleryIconSide: CGFloat = 70
        static let cameraIconSide: CGFloat = 84
        static let doneButtonInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 30)
        static let doneButtonBottomMargin: CGFloat = 28
        static let doneButtonBottomHeight: CGFloat = 44
    }
    
    let galleryButton = UIButton()
    let photoButton = UIButton()
    let videoButton = UIButton()
    let newBadgeLabel = UILabel()
    let cameraButton = UIButton()
    let infoButton = UIButton()
    let cameraTooltip: CameraTooltip = {
        let tooltip = CameraTooltip()
        tooltip.label.numberOfLines = 0
        tooltip.label.textAlignment = .center
        return tooltip
    }()
    let doneButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.setTitle(R.Strings.commonDone, for: .normal)
        button.contentEdgeInsets = Layout.doneButtonInsets
        return button
    }()
    private let infoButtonIncluded: Bool
    fileprivate var cameraButtonCenterXConstraint: NSLayoutConstraint?
    
    
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
        return [galleryButton, cameraButton, cameraTooltip, infoButton, doneButton].compactMap { $0 }.reduce(false) { (result, view) -> Bool in
            let convertedPoint = view.convert(point, from: self)
            return result || (!view.isHidden && view.point(inside: convertedPoint, with: event))
        }
    }
}


// MARK: - PostListingFooter

extension PostListingRedCamButtonFooter: PostListingFooter {

    func startRecording() {
        // This view doesn't implement video posting, check VPPostListingRedCamFooter
    }

    func stopRecording() {
        // This view doesn't implement video posting, check VPPostListingRedCamFooter
    }

    func updateToPhotoMode() {
        // This view doesn't implement video posting, check VPPostListingRedCamFooter
    }

    func updateToVideoMode() {
        // This view doesn't implement video posting, check VPPostListingRedCamFooter
    }

    func showTooltip(tooltipText: NSAttributedString?) {
        cameraTooltip.label.attributedText = tooltipText
        cameraTooltip.alpha = 0
        cameraTooltip.isHidden = false
        cameraTooltip.animateTo(alpha: 1.0, duration: 0.3, completion: nil)
    }

    func hideTooltip() {
        cameraTooltip.animateTo(alpha: 0.0, duration: 0.3) { (finished) in
            self.cameraTooltip.isHidden = false
        }
    }

    func update(scroll: CGFloat) {
        galleryButton.alpha = scroll
        infoButton.alpha = scroll
        doneButton.alpha = scroll
        cameraTooltip.alpha = scroll
        
        let rightOffset = cameraButton.frame.width/2 + Metrics.margin
        let movement = width/2 - rightOffset
        cameraButtonCenterXConstraint?.constant = movement * (1.0 - scroll)
    }

    func updateVideoRecordingDurationProgress(progress: CGFloat, recordingDuration: TimeInterval) {
        // This view doesn't implement video posting, check VPPostListingRedCamFooter
    }
}


// MARK: - Private methods

fileprivate extension PostListingRedCamButtonFooter {
    func setupUI() {
        galleryButton.setImage(R.Asset.IconsButtons.icPostGallery.image, for: .normal)
        
        cameraButton.setImage(R.Asset.IconsButtons.icPostTakePhotoIcon.image, for: .normal)
        cameraButton.setBackgroundImage(R.Asset.IconsButtons.icPostTakePhoto.image, for: .normal)
        
        infoButton.setImage(R.Asset.IconsButtons.info.image, for: .normal)
        addSubviewsForAutoLayout([galleryButton, doneButton, cameraButton, cameraTooltip, infoButton])
    }
    
    func setupAccessibilityIds() {
        galleryButton.set(accessibilityId: .postingGalleryButton)
        cameraButton.set(accessibilityId: .postingPhotoButton)
        infoButton.set(accessibilityId: .postingInfoButton)
        doneButton.set(accessibilityId: .postingDoneButton)
    }
    
    func setupLayout() {
        infoButton.layout(with: self)
            .trailing()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom()
        infoButton.layout()
            .width(Layout.galleryIconSide)
            .widthProportionalToHeight()
        
        galleryButton.layout(with: self)
            .leading()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom()
        galleryButton.layout()
            .width(Layout.galleryIconSide)
            .widthProportionalToHeight()
        
        cameraButton.layout(with: self)
            .centerX(constraintBlock: { [weak self] constraint in self?.cameraButtonCenterXConstraint = constraint })
            .top()
            .bottom(by: -Metrics.margin)
        cameraButton.layout().width(Layout.cameraIconSide).widthProportionalToHeight()

        cameraTooltip.layout(with: cameraButton).above(by: -Metrics.margin).centerX()
        cameraTooltip.layout(with: self).leading(by: Metrics.margin, relatedBy: .greaterThanOrEqual)

        doneButton.layout(with: self)
            .trailing(by: -Metrics.margin)
            .bottom(by: -Layout.doneButtonBottomMargin)
        doneButton.layout()
            .height(Layout.doneButtonBottomHeight)
        
        infoButton.isHidden = !infoButtonIncluded
    }
}
