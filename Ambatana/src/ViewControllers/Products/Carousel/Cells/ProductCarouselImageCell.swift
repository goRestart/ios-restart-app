//
//  ProductCarouselImageCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 18/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol ProductCarouselImageCellDelegate: class {
    func isZooming(_ zooming: Bool, pageAtIndex index: Int)
}

class ProductCarouselImageCell: UICollectionViewCell {
    
    static let identifier = "ProductCarouselImageCell"
    private static let zoomDecimalsRounding: CGFloat = 0.0001
    private static let minZoomScale: CGFloat = 0.5
    private static let maxZoomScale: CGFloat = 2


    var position: Int = 0
    var imageURL: URL?
    var imageView: UIImageView
    private var scrollView: UIScrollView
    private var backgroundImage: UIImageView
    private var effectsView: UIVisualEffectView
    private var referenceZoomLevel: CGFloat = 1.0

    weak var delegate: ProductCarouselImageCellDelegate?


    // MARK: - Lifecycle

    override init(frame: CGRect) {
        self.scrollView = UIScrollView()
        self.imageView = UIImageView()
        self.backgroundImage = UIImageView()
        let effect = UIBlurEffect(style: .light)
        self.effectsView = UIVisualEffectView(effect: effect)
        super.init(frame: frame)
        setupUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        resetZoom()
    }
}


// MARK: - Public methods

extension ProductCarouselImageCell {
    func setImage(_ image: UIImage?) {
        guard let img = image else { return }

        let imgAspectRatio = img.size.width / img.size.height
        let screenAspectRatio = UIScreen.main.bounds.width / UIScreen.main.bounds.height

        let zoomLevel = screenAspectRatio / imgAspectRatio
        let actualZoomLevel = imgAspectRatio >= LGUIKitConstants.horizontalImageMinAspectRatio ? zoomLevel : 1.0
        scrollView.minimumZoomScale = min(1, actualZoomLevel)

        imageView.bounds = CGRect(x: 0, y: 0, width: bounds.width/actualZoomLevel, height: bounds.height)
        scrollView.contentSize = imageView.bounds.size
        referenceZoomLevel = actualZoomLevel
        scrollView.setZoomScale(actualZoomLevel, animated: false)

        imageView.image = img
        backgroundImage.image = img

        scrollView.isScrollEnabled = false
        delegate?.isZooming(false, pageAtIndex: position)
    }

    func resetZoom() {
        scrollView.isScrollEnabled = false
        scrollView.zoomScale = referenceZoomLevel
    }
}


// MARK: - UIScrollViewDelegate

extension ProductCarouselImageCell: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)

        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                       y: scrollView.contentSize.height * 0.5 + offsetY)

        let zooming = scrollView.zoomScale > referenceZoomLevel
        scrollView.isScrollEnabled = zooming
        delegate?.isZooming(zooming, pageAtIndex: position)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}


// MARK: - Private methods
// MARK: > Setup

private extension ProductCarouselImageCell {
    func setupUI() {
        clipsToBounds = true

        addSubview(backgroundImage)
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = bounds
        backgroundImage.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(effectsView)
        effectsView.frame = bounds
        effectsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(scrollView)
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.contentMode = .center

        scrollView.addSubview(imageView)
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.isUserInteractionEnabled = true

        scrollView.contentSize = imageView.frame.size
        scrollView.minimumZoomScale = ProductCarouselImageCell.minZoomScale
        scrollView.maximumZoomScale = ProductCarouselImageCell.maxZoomScale
        scrollView.delegate = self
    }
}


// MARK: > Accessibility

private extension ProductCarouselImageCell {
    func setAccessibilityIds() {
        accessibilityId = .productCarouselImageCell
        imageView.accessibilityId = .productCarouselImageCellImageView
    }
}
