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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // Data
    var previewImage: UIImage?
    var imageURL: NSURL?
    var loaded: Bool = false
    
    // MARK: - Lifecycle
    
    public static func galleryItemView() -> GalleryPageView {
        guard let galleryPage = NSBundle.mainBundle().loadNibNamed("GalleryPageView", owner: self, options: nil).first as? GalleryPageView else { return GalleryPageView() }
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
            
            imageView.sd_setImageWithURL(imageURL, placeholderImage: nil, completed: { (_, error, cacheType, _) -> Void in
                // Finished loading
                self.activityIndicator.stopAnimating()
                
                self.loaded = error == nil
                
                // If not cached, then animate
                if cacheType == .None {
                    let alphaAnim = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                    alphaAnim.fromValue = 0
                    alphaAnim.toValue = 1
                    self.imageView.layer.pop_addAnimation(alphaAnim, forKey: "alpha")
                }
            })
        }
    }
    
    private func kk(previewImage: UIImage) {
        imageView.sd_setImageWithURL(self.imageURL, placeholderImage: previewImage, completed: { (_, error, cacheType, _) -> Void in
            self.loaded = error == nil
        })
    }
}
