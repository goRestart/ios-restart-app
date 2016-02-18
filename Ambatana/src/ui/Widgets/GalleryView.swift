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
    private var scrollView: UIScrollView = UIScrollView(frame: CGRect.zero)
    private var pageControlContainer: UIView = UIView(frame: CGRect.zero)
    private var pageControl: UIPageControl = UIPageControl(frame: CGRect.zero)
    private var tapRecognizer: UITapGestureRecognizer!
    
    private var pages: [GalleryPageView] = []
    
    public weak var delegate: GalleryViewDelegate?


    // MARK: - Lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let width = frame.width
        let height = frame.height

        // Place the subview at their correct positions & adjust the scroll view content size
        var x: CGFloat = 0
        for page in pages {
            page.frame = CGRect(x: x, y: 0, width: width, height: height)
            x += width
        }
        scrollView.contentSize = CGSize(width: x, height: height)

        pageControlContainer.layer.cornerRadius = pageControlContainer.frame.height / 2
    }


    // MARK: - Public methods
    
    public func addPageWithImageAtURL(url: NSURL, previewImage: UIImage?) {
        // Create the page
        let page = GalleryPageView.galleryItemView()
        page.frame = CGRectMake(scrollView.contentSize.width, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))
        page.previewImage = previewImage
        page.imageURL = url
        
        // Resize the scroll view's content size
        scrollView.contentSize = CGSize(width: CGRectGetMaxX(page.frame), height: CGRectGetHeight(frame))
        
        // Add the page
        pages.append(page)
        scrollView.addSubview(page)
        
        // Update page control
        pageControl.numberOfPages = pages.count
        pageControlContainer.hidden = pageControl.numberOfPages <= 1
        
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
        
        pageControlContainer.hidden = true
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
        pageControlContainer.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.16)
        pageControlContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControlContainer)

        pageControl.addTarget(self, action: Selector("pageControlPageChanged"),
            forControlEvents: UIControlEvents.ValueChanged)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControlContainer.addSubview(pageControl)
        
        // Constraints
        let scrollViewViews = ["scrollView": scrollView, "pageControlContainer": pageControlContainer]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil,
            views: scrollViewViews))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: [], metrics: nil,
            views: scrollViewViews))

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[pageControlContainer]-16-|", options: [],
            metrics: nil, views: scrollViewViews))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pageControlContainer]-16-|", options: [],
            metrics: nil, views: scrollViewViews))

        let pageControlContainerViews = ["pageControl": pageControl]
        pageControlContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[pageControl(18)]|",
            options: [], metrics: nil, views: pageControlContainerViews))
        pageControlContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[pageControl]-10-|",
            options: [], metrics: nil, views: pageControlContainerViews))
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
        guard index >= 0 && index < pages.count else { return }
        
        let page = pages[index]
        page.load()
    }
}
