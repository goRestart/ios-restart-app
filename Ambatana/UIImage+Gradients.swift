//
//  UIImage+Gradients.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 25/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func imageGradientWithStartColor(startColor: UIColor, endColor: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context : CGContextRef = UIGraphicsGetCurrentContext()
        let locations :[CGFloat] = [ 0.0, 1.0 ]
        let colors: CFArray = [startColor.CGColor, endColor.CGColor]
        let colorspace : CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let gradient : CGGradientRef = CGGradientCreateWithColors(colorspace, colors, locations)
        let startPoint : CGPoint = CGPointMake(size.width / 2.0, 0)
        let endPoint : CGPoint = CGPointMake(size.width / 2.0, size.height)
        CGContextDrawLinearGradient(context, gradient,startPoint, endPoint, 0)
        UIGraphicsEndImageContext()
        return UIImage(CGImage: CGBitmapContextCreateImage(context))!
    }

    class func randomImageGradientOfSize(size: CGSize) -> UIImage {
        let color1 = UIImage.randomColorForGradient()
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        var color2: UIColor!
        if color1.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            color2 = UIColor(hue: 0.95*hue, saturation: saturation, brightness: 0.80*brightness, alpha: alpha)
        } else { color2 = color1 }
        return imageGradientWithStartColor(color1, endColor: color2, size: size)
    }
    
    class func randomColorForGradient(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: alpha)
    }
    
    struct RGBAComponents {
        var r: CGFloat
        var g: CGFloat
        var b: CGFloat
        var a: CGFloat
    }
    
    class func rgbaFromUIColor(color: UIColor) -> RGBAComponents {
        let components = CGColorGetComponents(color.CGColor)
        return RGBAComponents(r: components[0], g: components[1], b: components[2], a: components[3])
    }
}
