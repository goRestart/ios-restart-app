//
//  Float+Rounding.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension Float {
    func roundNearest(nearest: Float) -> Float {
        return round(self * 1/nearest) / nearest
    }
}
