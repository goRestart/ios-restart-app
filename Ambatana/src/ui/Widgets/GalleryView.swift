//
//  GalleryView.swift
//  LetGo
//
//  Created by AHL on 26/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import SDWebImage

public protocol GalleryViewDelegate: class {
    func galleryView(galleryView: GalleryView, didSelectPageAt index: Int)
    func galleryView(galleryView: GalleryView, didPressPageAtIndex index: Int)
}

@IBDesignable public class GalleryView: UIView, UIScrollViewDelegate {
    private var scrollView: UIScrollView = UIScrollView(frame: CGRect.zero)
    private var tapRecognizer: UITapGestureRecognizer!
    
    private var pages: [GalleryPageView] = []
    
    public weak var delegate: GalleryViewDelegate?

    private(set) var currentPageIdx: Int = 0
    private var currentPage: GalleryPageView? {
        guard 0 < currentPageIdx && currentPageIdx < pages.count else { return nil }
        return pages[currentPageIdx]
    }


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
    }


    // MARK: - Public methods

    var contentSize: CGSize {
        return scrollView.contentSize
    }

    var contentOffset: CGPoint {
        get {
            return scrollView.contentOffset
        }
        set {
            scrollView.contentOffset = newValue
        }
    }

    public func setCurrentPageIndex(index: Int) {
        let actualIndex = max(0, min(index, pages.count - 1))
        currentPageIdx = actualIndex

        let pageWidth = CGRectGetWidth(scrollView.frame)
        let x = CGFloat(currentPageIdx) * pageWidth
        scrollView.contentOffset = CGPoint(x: x, y: 0)

        loadCurrentPageAndNeighbors()
    }

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
    }

    public func zoom(percentage: CGFloat) {
        guard let currentPage = currentPage else { return }
        currentPage.zoom(percentage)
    }


    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let newCurrentPage = calculateCurrentPage()
        guard newCurrentPage != currentPageIdx else { return }

        currentPageIdx = newCurrentPage
        delegate?.galleryView(self, didSelectPageAt: currentPageIdx)
        loadCurrentPageAndNeighbors()
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
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(GalleryView.scrollViewTapped(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)

        // Constraints
        let scrollViewViews = ["scrollView": scrollView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil,
            views: scrollViewViews))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: [], metrics: nil,
            views: scrollViewViews))
    }


    // MARK: > Actions
    
    @objc private func scrollViewTapped(recognizer: UIGestureRecognizer) {
        delegate?.galleryView(self, didPressPageAtIndex: currentPageIdx)
    }


    // MARK: > Page loading
    
    private func loadPageAtIndex(index: Int) {
        guard index >= 0 && index < pages.count else { return }
        
        let page = pages[index]
        page.load()
    }

    private func loadCurrentPageAndNeighbors() {
        loadPageAtIndex(currentPageIdx - 1)
        loadPageAtIndex(currentPageIdx)
        loadPageAtIndex(currentPageIdx + 1)
    }


    // MARK: > Helper

    private func calculateCurrentPage() -> Int {
        // Update current page idx when than 50% of the previous/next page is visible
        let contentOffsetX = scrollView.contentOffset.x
        let pageWidth = CGRectGetWidth(scrollView.frame)
        return Int(floor((contentOffsetX - pageWidth / 2) / pageWidth) + 1)
    }
}
