//
//  GalleryPageView.swift
//  LetGo
//
//  Created by AHL on 26/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import pop
import SDWebImage
import UIKit

public class GalleryPageView: UIView {
    
    // UI
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // Data
    var previewImage: UIImage?
    var imageURL: NSURL?
    var loaded: Bool = false
    
    // MARK: - Lifecycle
    
    public static func galleryItemView() -> GalleryPageView {
        guard let galleryPage = NSBundle.mainBundle().loadNibNamed("GalleryPageView", owner: self, options: nil).first as? GalleryPageView else { return GalleryPageView() }
        galleryPage.setup()
        return galleryPage
    }
    
    // MARK: Public methods
    
    /**
        Loads the page, if not previously loaded.
    */
    public func load() {
        // If already loaded then do nothing
        if loaded {
            return
        }

        // If has preview then show preview and then the actual image (w/o spinner)
        if let previewImage = previewImage {
            self.imageView.sd_setImageWithURL(self.imageURL, placeholderImage: previewImage, completed: { (_, error, cacheType, _) -> Void in
                self.loaded = error == nil
            })
        }
        // Otherwise show the actual image (with spinner)
        else {
            // Start loading
            activityIndicator.startAnimating()
            
            imageView.sd_setImageWithURL(imageURL, placeholderImage: nil, completed: {
                [weak self] (_, error, cacheType, _) in
                    guard let strongSelf = self else { return }

                    strongSelf.activityIndicator.stopAnimating()
                    strongSelf.loaded = error == nil

                    // If not cached, then animate
                    if cacheType == .None {
                        let alphaAnim = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                        alphaAnim.fromValue = 0
                        alphaAnim.toValue = 1
                        strongSelf.imageView.layer.pop_addAnimation(alphaAnim, forKey: "alpha")
                    }
            })
        }
    }

    public func zoom(percentage: CGFloat) {
        let actualPercentage = max(0, min(1, percentage))
        let diff = scrollView.maximumZoomScale - scrollView.minimumZoomScale
        let zoomScale = scrollView.minimumZoomScale + actualPercentage * diff
        scrollView.zoomScale = zoomScale
    }


    // MARK: - Private methods

    private func setup() {
        scrollView.userInteractionEnabled = false
        scrollView.clipsToBounds = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 1.5
        imageView.clipsToBounds = false
    }
}

// MARK: - UIScrollViewDelegate

extension GalleryPageView: UIScrollViewDelegate {
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
