//
//  ImageManager.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 19/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import Parse
import UIKit

public class ImageHelper {

    // MARK: - Public methods
 
    public static func fullImageURLForProduct(product: PFObject) -> NSURL? {
        if let imageFile = product[kLetGoProductFirstImageKey] as? PFFile, let imageURLStr = imageFile.url {
            return NSURL(string: imageURLStr)
        }
        return nil
    }
    
    public static func fullImageURLsForProduct(product: PFObject) -> [NSURL] {
        var result: [NSURL] = []
        for imageKey in kLetGoProductImageKeys {
            if let imageFile = product[imageKey] as? PFFile, let imageURLStr = imageFile.url, let imageURL = NSURL(string: imageURLStr) {
                result.append(imageURL)
            }
        }
        return result
    }
    
    public static func thumbnailURLForProduct(product: PFObject) -> NSURL? {
        if let objectId = product.objectId, let firstImageFile = product[kLetGoProductFirstImageKey] as? PFFile, let firstImageURL = firstImageFile.url {
            let baseURLStr = baseURLForProductId(objectId, imageURL: firstImageURL) + "_thumb.jpg"
            return NSURL(string: baseURLStr)
        }
        return nil
    }
    
    // MARK: - Private methods
    
    // get the baseURL for a image file of a product object
    private static func baseURLForProductId(productId: String, imageURL: String) -> String {
        // 1. Calculate the md5 of productId to get the folder structure.
        let folderBase = productId.md5()
        // 2. Split the string in 4 pairs
        let folderStructure = self.getFolderStructureForString(folderBase, inGroupsOf: 2, numberOfGroups: 4)
        // 3. generate the filename with the imageURL
        let filename = imageURL.md5()
        // 4. return the base url
        return "\(EnvironmentProxy.sharedInstance.imagesBaseURL)/\(folderStructure)\(filename)"
    }
    
    private static func getFolderStructureForString(string: String, inGroupsOf group: Int, numberOfGroups numGroups: Int) -> String {
        // safety check
        if count(string) < group * numGroups { return "/" }
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
}
