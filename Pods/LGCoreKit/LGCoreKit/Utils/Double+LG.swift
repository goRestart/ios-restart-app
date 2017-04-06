//
//  Double+LG.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 09/02/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

extension Double {
    
    func getCoordinates(with long: Double) -> (Double, Double) {
        let π = M_PI
        let exponent = exp((0.5 - self) * 4 * π)
        
        return (asin((exponent - 1) / (exponent + 1)) * 180 / π, long * 360 - 180)
    }
}
