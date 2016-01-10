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

enum GalleryPageControlPosition {
    case Center
    case Right
}

@IBDesignable public class GalleryView: UIView, UIScrollViewDelegate {

    var pageControlPosition = GalleryPageControlPosition.Right {
        didSet {
            placePageControl()
        }
    }

    var bottomGradient = true {
        didSet {
            shadowGradientView.hidden = !bottomGradient
        }
    }
    
    // UI
    private var scrollView: UIScrollView
    private var shadowGradientView: UIView
    private var pageControl: UIPageControl
    private var pageControlBottomConstraint: NSLayoutConstraint?
    private var pageControlYConstraint: NSLayoutConstraint?
    private var tapRecognizer: UITapGestureRecognizer!
    
    // Data
    private var pages: [GalleryPageView] = []
    
    // Delegate
    public weak var delegate: GalleryViewDelegate?
    
    // MARK: - Lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        scrollView = UIScrollView(frame: CGRect.zero)
        pageControl = UIPageControl(frame: CGRect.zero)
        shadowGradientView = UIView(frame: CGRect.zero)
        super.init(coder: aDecoder)

        setupUI()
    }
    
    public override init(frame: CGRect) {
        scrollView = UIScrollView(frame: frame)
        pageControl = UIPageControl(frame: frame)
        shadowGradientView = UIView(frame: CGRect.zero)
        super.init(frame: frame)
        
        setupUI()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let width = frame.width
        let height = frame.height

        // Place the subview at their correct positions
        var x: CGFloat = 0
        for page in pages {
            page.frame = CGRect(x: x, y: 0, width: width, height: height)
            x += width
        }
        // Adjust the scroll view content size
        scrollView.contentSize = CGSize(width: x, height: height)

        // Adjust gradient layer
        if let layers = shadowGradientView.layer.sublayers {
            for layer in layers {
                layer.frame = shadowGradientView.bounds
            }
        }
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

        //Bottom shadow gradient
        addSubview(shadowGradientView)
        placeShadowLayer()
        shadowGradientView.hidden = !bottomGradient

        // Tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewTapped:")
        tapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapRecognizer)
        
        // Page control
        pageControl.addTarget(self, action: Selector("pageControlPageChanged"),
            forControlEvents: UIControlEvents.ValueChanged)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControl)
        
        // Constraints
        let scrollViewViews = ["scrollView": scrollView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: [], metrics: nil,
            views: scrollViewViews))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: [], metrics: nil,
            views: scrollViewViews))

        placePageControl()
    }

    private func placeShadowLayer() {
        shadowGradientView.userInteractionEnabled = false
        shadowGradientView.translatesAutoresizingMaskIntoConstraints = false
        shadowGradientView.backgroundColor = UIColor.clearColor()
        let heightConstraint = NSLayoutConstraint(item: shadowGradientView, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 150)
        shadowGradientView.addConstraint(heightConstraint)
        let widthConstraint = NSLayoutConstraint(item: shadowGradientView, attribute: .Width, relatedBy: .Equal,
            toItem: self, attribute: .Width, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: shadowGradientView, attribute: .Bottom, relatedBy: .Equal,
            toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        addConstraints([widthConstraint,bottomConstraint])

        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.0,0.4],
            locations: [0.0,1.0])
        shadowLayer.frame = shadowGradientView.bounds
        shadowGradientView.layer.insertSublayer(shadowLayer, atIndex: 0)
    }

    private func placePageControl() {
        if let bottomConstr = pageControlBottomConstraint, let yConstr = pageControlYConstraint {
            removeConstraint(bottomConstr)
            removeConstraint(yConstr)
        }

        switch pageControlPosition {
        case .Center:
            pageControlBottomConstraint = NSLayoutConstraint(item: pageControl, attribute: .Bottom, relatedBy: .Equal,
                toItem: self, attribute: .Bottom, multiplier: 1, constant: 6)
            pageControlYConstraint = NSLayoutConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal,
                toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        case .Right:
            pageControlBottomConstraint = NSLayoutConstraint(item: pageControl, attribute: .Bottom, relatedBy: .Equal,
                toItem: self, attribute: .Bottom, multiplier: 1, constant: -6)
            pageControlYConstraint = NSLayoutConstraint(item: pageControl, attribute: .Right, relatedBy: .Equal,
                toItem: self, attribute: .Right, multiplier: 1, constant: -16)
        }
        addConstraints([pageControlBottomConstraint!, pageControlYConstraint!])
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
