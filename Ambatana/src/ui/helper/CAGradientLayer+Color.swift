//
//  CAGradientLayer+Color.swift
//  LetGo
//
//  Created by Eli Kohen on 04/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

extension CAGradientLayer {

    static func gradientWithColor(_ mainColor: UIColor, alphas: [Float]?, locations: [NSNumber]? = nil) -> CAGradientLayer {

        let gradientLayer: CAGradientLayer = CAGradientLayer()

        if let alphas = alphas, let locations = locations {
            guard alphas.count == locations.count else { return gradientLayer }
            var gradientColors: [Any] = []
            for alpha in alphas {
                gradientColors.append(mainColor.withAlphaComponent(CGFloat(alpha)).cgColor)
            }
            gradientLayer.colors = gradientColors
            gradientLayer.locations = locations
        } else {
            let topColor = mainColor.withAlphaComponent(0.0)
            let gradientColors: [Any] = [topColor.cgColor, mainColor.cgColor]
            gradientLayer.colors = gradientColors
            gradientLayer.locations = [0.0,1.0]
        }

        return gradientLayer
    }
}
