//
//  UIImage+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 21/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UIImage {
    
    func rotatedImage(clockWise: Bool = true) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSize(width: size.height, height: size.width))
        let context = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(context, 0.5 * size.height, 0.5 * size.width)
        if clockWise {
            CGContextRotateCTM(context, CGFloat(M_PI_2))
        } else {
            CGContextRotateCTM(context, CGFloat(-M_PI_2))
        }
        CGContextTranslateCTM(context, -0.5 * size.width, -0.5 * size.height)
        
        drawAtPoint(CGPointMake(0, 0))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

    func upsideDownImage() -> UIImage? {
        guard let cgImg = self.CGImage else { return nil }
        return UIImage.init(CGImage: cgImg, scale: self.scale, orientation: .DownMirrored)
    }
}
