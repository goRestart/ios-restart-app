//
//  Float+Rounding.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension Float {
    func roundNearest(nearest: Float) -> Float {
        let n = 1/nearest
        return round(self * n) / n
    }
}
