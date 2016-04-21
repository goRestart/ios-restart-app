//
//  ProductCarouselImageCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 18/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class ProductCarouselImageCell: UICollectionViewCell, UIScrollViewDelegate {
    
    static let identifier = "ProductCarouselImageCell"
    var scrollView: UIScrollView
    var imageView: UIImageView
    
    override init(frame: CGRect) {
        self.scrollView = UIScrollView()
        self.imageView = UIImageView()
        super.init(frame: frame)
        setupUI()
        backgroundColor = StyleHelper.productCellImageBgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(image: UIImage?) {
        guard let img = image else { return }
        var aspectRatio = img.size.width / img.size.height

        
        let screenAspectRatio = UIScreen.mainScreen().bounds.width / UIScreen.mainScreen().bounds.height

        
        if aspectRatio > 1 {
//            aspectRatio = img.size.height / img.size.width
            imageView.image = img.rotatedImage()
            scrollView.minimumZoomScale = screenAspectRatio * aspectRatio
        } else {
            imageView.image = img
            scrollView.minimumZoomScale = screenAspectRatio / aspectRatio
        }
        
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
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
        
        imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    }
}
