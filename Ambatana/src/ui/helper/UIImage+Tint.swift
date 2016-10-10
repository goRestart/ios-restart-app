//
//  UIImage+Tint.swift
//  LetGo
//
//  Created by AHL on 17/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

// http://stackoverflow.com/questions/19274789/how-can-i-change-image-tintcolor-in-ios-and-watchkit

extension UIImage {
    func imageWithColor(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        let rect = CGRectMake(0, 0, size.width, size.height) as CGRect
        guard let CGImage = CGImage else { return nil }
        CGContextClipToMask(context, rect, CGImage)
        color.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
