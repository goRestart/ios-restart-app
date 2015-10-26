//
//  GalleryView.swift
//  LetGo
//
//  Created by AHL on 26/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import SDWebImage

@objc public protocol GalleryViewDelegate {
     optional func galleryView(galleryView: GalleryView, didPressPageAtIndex index: Int)
}

@IBDesignable public class GalleryView: UIView, UIScrollViewDelegate {
    
    // UI
    private var scrollView: UIScrollView
    private var pageControl: UIPageControl
    private var tapRecognizer: UITapGestureRecognizer!
    
    // Data
    private var pages: [GalleryPageView] = []
    
    // Delegate
    public weak var delegate: GalleryViewDelegate?
    
    // MARK: - Lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        scrollView = UIScrollView(frame: CGRectZero)
        pageControl = UIPageControl(frame: CGRectZero)
        super.init(coder: aDecoder)

        setupUI()
    }
    
    public override init(frame: CGRect) {
        scrollView = UIScrollView(frame: frame)
        pageControl = UIPageControl(frame: frame)
        super.init(frame: frame)
        
        setupUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let width = CGRectGetWidth(frame)
        let height = CGRectGetHeight(frame)

        // Place the subview at their correct positions
        var x: CGFloat = 0
        for page in pages {
            page.frame = CGRect(x: x, y: 0, width: width, height: height)
            x += width
        }
        // Adjust the scroll view content size
        scrollView.contentSize = CGSize(width: x, height: height)
    }
    
    // MARK: - Public methods
    
    public func addPageWithImageAtURL(url: NSURL, previewURL: NSURL?) {
        // Create the page
        let page = GalleryPageView.galleryItemView()
        page.frame = CGRectMake(scrollView.contentSize.width, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))
        page.previewURL = previewURL
        page.imageURL = url
        
        // Resize the scroll view's content size
        scrollView.contentSize = CGSize(width: CGRectGetMaxX(page.frame), height: CGRectGetHeight(frame))
        
        // Add the page
        pages.append(page)
        scrollView.addSubview(page)
        
        // Update page control
        pageControl.numberOfPages = pages.count
        pageControl.hidden = pageControl.numberOfPages <= 1
        
        // Load if first of the two pages
        let pageIndex = pages.count - 1
        if pageIndex < 2 {
            loadPageAtIndex(pageIndex)
        }
    }
    
    public func removePages() {
        scrollView.contentSize = CGSizeZero
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        pages = []
        
        pageControl.hidden = true
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        // Switch the indicator when more than 50% of the previous/next page is visible
        let contentOffsetX = scrollView.contentOffset.x
        let pageWidth = CGRectGetWidth(scrollView.frame)
        let currentPage = Int(floor((contentOffsetX - pageWidth / 2) / pageWidth) + 1)
        pageControl.currentPage = currentPage
        
        // Load previous, current and next page
        loadPageAtIndex(currentPage - 1)
        loadPageAtIndex(currentPage)
        loadPageAtIndex(currentPage + 1)
    }
    
    // MARK: - Private methods
    
    // MARK: > Setup
    
    private func setupUI() {
        clipsToBounds = true
        
        // Scroll view
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        // Tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewTapped:")
        tapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
        
        // Page control
        pageControl.addTarget(self, action: Selector("pageControlPageChanged"), forControlEvents: UIControlEvents.ValueChanged)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControl)
        
        // Constraints
        let scrollViewViews = ["scrollView": scrollView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil, views: scrollViewViews))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: [], metrics: nil, views: scrollViewViews))
        
        let pageControlViews = ["pageControl": pageControl]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pageControl]-(-6)-|", options: [], metrics: nil, views: pageControlViews))
        addConstraint(NSLayoutConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
    }
    
    // MARK: > Actions
    
    dynamic private func pageControlPageChanged() {
        
        // Load previous, current and next page
        let page = pageControl.currentPage
        loadPageAtIndex(page - 1)
        loadPageAtIndex(page)
        loadPageAtIndex(page + 1)
        
        // Update the scroll view to the appropriate page
        let pageWidth = CGRectGetWidth(scrollView.frame)
        let rectVisible = CGRectMake(pageWidth * CGFloat(page), 0, pageWidth, CGRectGetHeight(scrollView.frame))
        scrollView.scrollRectToVisible(rectVisible, animated: true)
    }
    
    @objc private func scrollViewTapped(recognizer: UIGestureRecognizer) {
        let page = pageControl.currentPage
        if page < pages.count {
            delegate?.galleryView?(self, didPressPageAtIndex: page)
        }
    }
    
    // MARK: > Page loading
    
    private func loadPageAtIndex(index: Int) {
        if index < 0 || index >= pages.count {
            return
        }
        
        let page = pages[index]
        page.load()
    }
}
