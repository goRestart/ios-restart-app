//
//  CAGradientLayer+Color.swift
//  LetGo
//
//  Created by Eli Kohen on 04/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

extension CAGradientLayer {

    static func gradientWithColor(mainColor: UIColor, alphas: [Float]?, locations: [NSNumber]? = nil) -> CAGradientLayer {

        let gradientLayer: CAGradientLayer = CAGradientLayer()

        if let alphas = alphas, let locations = locations {
            guard alphas.count == locations.count else { return gradientLayer }
            var gradientColors: [AnyObject] = []
            for alpha in alphas {
                gradientColors.append(mainColor.colorWithAlphaComponent(CGFloat(alpha)).CGColor)
            }
            gradientLayer.colors = gradientColors
            gradientLayer.locations = locations
        } else {
            let topColor = mainColor.colorWithAlphaComponent(0.0)
            let gradientColors: Array <AnyObject> = [topColor.CGColor, mainColor.CGColor]
            gradientLayer.colors = gradientColors
            gradientLayer.locations = [0.0,1.0]
        }

        return gradientLayer
    }
}