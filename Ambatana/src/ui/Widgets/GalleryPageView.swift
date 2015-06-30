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
    var imageURL: NSURL?
    var loaded: Bool = false
    
    // MARK: - Lifecycle
    
    public static func galleryItemView() -> GalleryPageView {
        return NSBundle.mainBundle().loadNibNamed("GalleryPageView", owner: self, options: nil).first as! GalleryPageView
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
        
        // Start loading
        activityIndicator.startAnimating()
        
        imageView.sd_setImageWithURL(imageURL, placeholderImage: nil, completed: {
            [weak self] (image, error, cacheType, url) -> Void in
            
            // Finished loading
            self?.activityIndicator.stopAnimating()
            
            if error == nil{
                self?.loaded = true
            }
            
            // If not cached, then animate
            if cacheType == .None {
                let alphaAnim = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                alphaAnim.fromValue = 0
                alphaAnim.toValue = 1
                self?.imageView.layer.pop_addAnimation(alphaAnim, forKey: "alpha")
            }
        })
    }
}
