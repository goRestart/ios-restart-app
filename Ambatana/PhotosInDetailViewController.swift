//
//  PhotosInDetailViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 12/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import pop
import SDWebImage
import UIKit

private let kLetGoPhotoDetailsInnerImageViewTag = 100

class PhotosInDetailViewController: UIViewController, UIScrollViewDelegate {
    // outlets & buttons
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // data
    var pageControlBeingUsed = false
    var imageURLs: [NSURL] = []
    var initialImageToShow = 0
    var productName = NSLocalizedString("product_gallery_title", comment: "")
    
    override func viewDidLoad() {
        hidesBottomBarWhenPushed = true
        
        super.viewDidLoad()
        self.setLetGoNavigationBarStyle(title: productName)
//        self.pageControl.numberOfPages = 0
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if imageURLs.count > 0 {
            showImages()
        }
    }
    
    // MARK: - Page control
    
    @IBAction func pageChanged(sender: AnyObject) {
        let offset = scrollView.frame.size.width * CGFloat(pageControl.currentPage)
        self.scrollView.scrollRectToVisible(CGRectMake(offset, 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: true)
        pageControlBeingUsed = true
    }
    
    // MARK: - ScrollView
    func showImages() {
        var offset: CGFloat = 0
        // add the images
        for imageURL in imageURLs {
            let innerFrame = CGRectMake(offset, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)
            let imageView = UIImageView(frame: innerFrame)
            imageView.contentMode = .ScaleAspectFit
            imageView.clipsToBounds = true
            imageView.tag = kLetGoPhotoDetailsInnerImageViewTag
            imageView.sd_setImageWithURL(imageURL, placeholderImage: nil, completed: {
                [weak self] (image, error, cacheType, url) -> Void in
                
                if error == nil {
                    if cacheType == .None {
                        let alphaAnim = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                        alphaAnim.fromValue = 0
                        alphaAnim.toValue = 1
                        imageView.layer.pop_addAnimation(alphaAnim, forKey: "alpha")
                    }
                }
            })
            
            
            let innerScrollView = UIScrollView(frame: innerFrame)
            // scrollview zooming
            innerScrollView.contentSize = imageView.bounds.size
            let scaleWidth = innerFrame.size.width / innerScrollView.contentSize.width
            let scaleHeight = innerFrame.size.height / innerScrollView.contentSize.height
            let minScale = min(scaleWidth, scaleHeight);
            innerScrollView.delegate = self
            innerScrollView.addSubview(imageView)
            innerScrollView.minimumZoomScale = minScale
            innerScrollView.maximumZoomScale = 2.0
            innerScrollView.zoomScale = minScale
            innerScrollView.showsHorizontalScrollIndicator = false
            innerScrollView.showsVerticalScrollIndicator = false
            
            centerScrollViewContents(innerScrollView)
            
            scrollView.addSubview(innerScrollView)
            offset += self.scrollView.frame.size.width
        }
        // set the images scrollview global offset
        self.scrollView.contentSize = CGSizeMake(offset, self.scrollView.frame.size.height)
        
        // show with fade-in animation
        self.pageControl.numberOfPages = self.imageURLs.count
        self.pageControl.hidden = self.pageControl.numberOfPages <= 1
        if self.initialImageToShow >= 0 && self.initialImageToShow < self.imageURLs.count {
            pageControl.currentPage = initialImageToShow;

            offset = scrollView.frame.size.width * CGFloat(pageControl.currentPage)
            self.scrollView.scrollRectToVisible(CGRectMake(offset, 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: false)
        }
    }
    
    func centerScrollViewContents(scrollView: UIScrollView) {
        let boundsSize = scrollView.frame.size
        if let imageView = scrollView.viewWithTag(kLetGoPhotoDetailsInnerImageViewTag) as? UIImageView {
            var contentsFrame = imageView.frame
            
            if contentsFrame.size.width < boundsSize.width {
                contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
            } else {
                contentsFrame.origin.x = 0.0
            }
            
            if contentsFrame.size.height < boundsSize.height {
                contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
            } else {
                contentsFrame.origin.y = 0.0
            }
            
            imageView.frame = contentsFrame
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if scrollView == self.scrollView { return nil }
        return scrollView.viewWithTag(kLetGoPhotoDetailsInnerImageViewTag)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !pageControlBeingUsed {
            let newPage = floor((self.scrollView.contentOffset.x - self.scrollView.frame.size.width / 2) / self.scrollView.frame.size.width) + 1
            pageControl.currentPage = Int(newPage)
        }
        
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        if scrollView != self.scrollView {
            centerScrollViewContents(scrollView)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pageControlBeingUsed = false
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControlBeingUsed = false
    }
    
}
