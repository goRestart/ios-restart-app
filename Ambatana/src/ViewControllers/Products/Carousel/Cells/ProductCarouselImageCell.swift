//
//  ProductCarouselImageCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 18/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

class ProductCarouselImageCell: UICollectionViewCell, UIScrollViewDelegate {
    
    static let identifier = "ProductCarouselImageCell"
    private static let zoomDecimalsRounding: CGFloat = 0.0001

    var zooming = PublishSubject<(Bool, Int)>()
    var position: Int = 0
    var imageURL: NSURL?
    var imageView: UIImageView
    private var scrollView: UIScrollView
    private var backgroundImage: UIImageView
    private var effectsView: UIVisualEffectView
    private var referenceZoomLevel: CGFloat = 1.0
    
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

        zooming.onNext((false, position))
    }

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
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2.0
        scrollView.delegate = self
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    override func prepareForReuse() {
        zooming.onCompleted()
        zooming = PublishSubject<(Bool, Int)>()
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        
        imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY)

        let zoomScale = scrollView.zoomScale.roundNearest(ProductCarouselImageCell.zoomDecimalsRounding)
        let referenceZoomScale = referenceZoomLevel.roundNearest(ProductCarouselImageCell.zoomDecimalsRounding)
        let isZooming = zoomScale > referenceZoomScale
        zooming.onNext((isZooming, position))
    }
}


extension ProductCarouselImageCell {
    private func setAccessibilityIds() {
        self.accessibilityId = .ProductCarouselImageCell
        imageView.accessibilityId = .ProductCarouselImageCellImageView
    }
}
