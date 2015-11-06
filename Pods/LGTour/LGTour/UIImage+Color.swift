//
//  UIImage+Color.swift
//  LGTour
//
//  Created by Albert Hernández López on 04/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import UIKit

// http://stackoverflow.com/questions/19274789/how-can-i-change-image-tintcolor-in-ios-and-watchkit
extension UIImage {
    /**
        Returns an 1x1px image with the given color.
    
        - parameter color: The color.
        - returns: A 1x1 colored image.
    */
    static func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}