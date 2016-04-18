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
    
    
    func setupUI() {
        addSubview(scrollView)
        scrollView.frame = bounds
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
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
    }
}
