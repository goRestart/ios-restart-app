//
//  UIImage+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 21/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UIImage {
    
    func rotatedImage(_ clockWise: Bool = true) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSize(width: size.height, height: size.width))
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        context.translateBy(x: 0.5 * size.height, y: 0.5 * size.width)
        if clockWise {
            context.rotate(by: CGFloat(Double.pi/2))
        } else {
            context.rotate(by: CGFloat(-Double.pi/2))
        }
        context.translateBy(x: -0.5 * size.width, y: -0.5 * size.height)
        
        draw(at: CGPoint(x: 0, y: 0))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? self
    }
}
