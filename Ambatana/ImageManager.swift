//
//  ImageManager.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 19/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

// private singleton instance
private let _singletonInstance = ImageManager()

// constants
private let kAmbatanaMaxImageCacheSize = 104857600.0 // 100 MB
private let kAmbatanaThumbnailBaseURL = "http://3rdparty.ambatana.com/images/"
private let kAmbatanaImageCacheEnabled = true

/**
 * The ImageManager class is in charge of retrieving and caching images from URLs.
 * It implements a really simple internal cache.
 * ImageManager follows the Singleton design scheme, so it must be accessed by means of the sharedInstance class property.
 */
class ImageManager: NSObject {
    
    // data
    var imageCache: [String:UIImage] = [:]
    var currentCacheSize = 0.0
    
    /** Shared instance */
    class var sharedInstance: ImageManager {
        return _singletonInstance
    }
    
    /** Asynchronously retrieves a image from a URL. If the image is in the cache, it retrieves if from the cache first */
    func retrieveImageFromURLString(urlString: String, completion: (success: Bool, image: UIImage?) -> Void, andAddToCache addToCache: Bool = kAmbatanaImageCacheEnabled) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            // try the cache first
            if let cachedImage = self.imageCache[urlString] {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(success: true, image: cachedImage)
                })
            }
            // if the image is not in the cache, retrieve it.
            else {
                if let url = NSURL(string: urlString) {
                    if let imageData = NSData(contentsOfURL: url) {
                        // generate the image
                        let newImage = UIImage(data: imageData)
                        // store in the cache if enough space.
                        if addToCache && (self.currentCacheSize + Double(imageData.length)) < kAmbatanaMaxImageCacheSize {
                            self.currentCacheSize += Double(imageData.length)
                            self.imageCache[urlString] = newImage
                        }
                        // call the completion handler
                        completion(success: true, image: newImage)
                    } else { completion(success: false, image: nil) } // error. Unable to retrieve image.
                } else { completion(success: false, image: nil) } // error, malformed URL.
            }
        })
    }
    
    /** SYNCHRONOUSLY retrieves a image from a URL. If the image is in the cache, it retrieves if from the cache first */
    func retrieveImageSynchronouslyFromURLString(urlString: String, andAddToCache addToCache: Bool = kAmbatanaImageCacheEnabled) -> UIImage? {
        // try the cache first
        if let cachedImage = self.imageCache[urlString] {
            return cachedImage
        }
        // if the image is not in the cache, retrieve it.
        else {
            if let url = NSURL(string: urlString) {
                if let imageData = NSData(contentsOfURL: url) {
                    // generate the image
                    let newImage = UIImage(data: imageData)
                    // store in the cache if enough space.
                    if addToCache && (self.currentCacheSize + Double(imageData.length)) < kAmbatanaMaxImageCacheSize {
                        self.currentCacheSize += Double(imageData.length)
                        self.imageCache[urlString] = newImage
                    }
                    // return the image
                    return newImage
                } else { return nil } // error. Unable to retrieve image.
            } else { return nil } // error, malformed URL.
        }
    }
    
    internal func getFolderStructureForString(string: String, inGroupsOf group: Int, numberOfGroups numGroups: Int) -> String {
        // safety check
        if countElements(string) < group * numGroups { return "/" }
        // initialize structures
        var result = ""
        var startIndex = string.startIndex
        var endIndex = advance(startIndex, group)
        
        // iterate adding numGroups of group elements from string
        for (var i = 0; i < numGroups; i++) {
            result += string.substringWithRange(Range<String.Index>(start: startIndex, end: endIndex)) + "/"
            startIndex = advance(startIndex, group)
            endIndex = advance(endIndex, group)
        }
        
        return result
    }

    // get the baseURL for a image file of a product object
    internal func calculateBaseURLForProductImage(productId: String, imageURL: String) -> String {
        // 1. Calculate the md5 of productId to get the folder structure.
        let folderBase = productId.md5()
        // 2. Split the string in 4 pairs
        let folderStructure = self.getFolderStructureForString(folderBase, inGroupsOf: 2, numberOfGroups: 4)
        // 3. generate the filename with the imageURL
        let filename = imageURL.md5()
        // 4. return the base url
        return "\(kAmbatanaThumbnailBaseURL)\(folderStructure)\(filename)"
    }
    
    // get the big image URL from a given image file of a product object
    func calculateBigImageURLForProductImage(productId: String, imageURL: String) -> String {
        return self.calculateBaseURLForProductImage(productId, imageURL: imageURL) + ".jpg"
    }
    
    // get the thumbnail image URL from a given image file of a product object
    func calculateThumnbailImageURLForProductImage(productId: String, imageURL: String) -> String {
        return self.calculateBaseURLForProductImage(productId, imageURL: imageURL) + "_thumb.jpg"
    }
    
    
    // clears the cache
    func clearCache() {
        imageCache = [:]
        currentCacheSize = 0.0
    }
}
