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
    var scrollView: UIScrollView
    var imageView: UIImageView
    var zoomLevel = PublishSubject<CGFloat>()
    
    override init(frame: CGRect) {
        self.scrollView = UIScrollView()
        self.imageView = UIImageView()
        super.init(frame: frame)
        setupUI()
        backgroundColor = UIColor.placeholderBackgroundColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(image: UIImage?) {
        guard let img = image else { return }
        let aspectRatio = img.size.width / img.size.height
        let screenAspectRatio = UIScreen.mainScreen().bounds.width / UIScreen.mainScreen().bounds.height
        imageView.image = aspectRatio > 1 ? img.rotatedImage() : img
        let zoomLevel = aspectRatio > 1 ? screenAspectRatio * aspectRatio : screenAspectRatio / aspectRatio
        scrollView.minimumZoomScale = min(1, zoomLevel)
    }
    
    func setupUI() {
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
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        scrollView.delegate = self
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func prepareForReuse() {
        scrollView.zoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        zoomLevel.onCompleted()
        zoomLevel = PublishSubject<CGFloat>()
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
        
        imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
        
        zoomLevel.onNext(scrollView.zoomScale)
    }
}
