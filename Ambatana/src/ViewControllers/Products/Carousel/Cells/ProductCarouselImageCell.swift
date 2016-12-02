//
//  ProductCarouselImageCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 18/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol ProductCarouselImageCellDelegate: class {
    func isZooming(zooming: Bool, pageAtIndex index: Int)
}

class ProductCarouselImageCell: UICollectionViewCell {
    
    static let identifier = "ProductCarouselImageCell"
    private static let zoomDecimalsRounding: CGFloat = 0.0001
    private static let minZoomScale: CGFloat = 0.5
    private static let maxZoomScale: CGFloat = 2


    var position: Int = 0
    var imageURL: NSURL?
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
        let effect = UIBlurEffect(style: .Light)
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
    func setImage(image: UIImage?) {
        guard let img = image else { return }
        let aspectRatio = img.size.width / img.size.height
        let screenAspectRatio = UIScreen.mainScreen().bounds.width / UIScreen.mainScreen().bounds.height
        let zoomLevel = (screenAspectRatio / aspectRatio).roundNearest(ProductCarouselImageCell.zoomDecimalsRounding)
        scrollView.minimumZoomScale = min(1, zoomLevel)

        imageView.bounds = CGRect(x: 0, y: 0, width: bounds.width/zoomLevel, height: bounds.height)
        scrollView.contentSize = imageView.bounds.size
        referenceZoomLevel = zoomLevel
        scrollView.setZoomScale(zoomLevel, animated: false)

        imageView.image = img
        backgroundImage.image = img

        delegate?.isZooming(false, pageAtIndex: position)
    }

    func resetZoom() {
        scrollView.zoomScale = referenceZoomLevel
    }
}


// MARK: - UIScrollViewDelegate

extension ProductCarouselImageCell: UIScrollViewDelegate {
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)

        imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY)

        let zoomScale = scrollView.zoomScale.roundNearest(ProductCarouselImageCell.zoomDecimalsRounding)
        let referenceZoomScale = referenceZoomLevel.roundNearest(ProductCarouselImageCell.zoomDecimalsRounding)
        let zooming = zoomScale > referenceZoomScale
        delegate?.isZooming(zooming, pageAtIndex: position)
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}


// MARK: - Private methods
// MARK: > Setup

private extension ProductCarouselImageCell {
    func setupUI() {
        clipsToBounds = true

        addSubview(backgroundImage)
        backgroundImage.contentMode = .ScaleAspectFill
        backgroundImage.frame = bounds
        backgroundImage.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

        addSubview(effectsView)
        effectsView.frame = bounds
        effectsView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

        addSubview(scrollView)
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.contentMode = .Center

        scrollView.addSubview(imageView)
        imageView.frame = bounds
        imageView.contentMode = .ScaleAspectFill
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        imageView.userInteractionEnabled = true

        scrollView.contentSize = imageView.frame.size
        scrollView.minimumZoomScale = ProductCarouselImageCell.minZoomScale
        scrollView.maximumZoomScale = ProductCarouselImageCell.maxZoomScale
        scrollView.delegate = self
    }
}


// MARK: > Accessibility

private extension ProductCarouselImageCell {
    func setAccessibilityIds() {
        accessibilityId = .ProductCarouselImageCell
        imageView.accessibilityId = .ProductCarouselImageCellImageView
    }
}
