//
//  StyleHelper.swift
//  LetGo
//
//  Created by AHL on 27/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import Foundation

class StyleHelper {

    static let CELL_BG_COLOR = [UIColor(rgb: 0xC2185B), UIColor(rgb: 0xE91E63), UIColor(rgb: 0xF8BBD0),
                                UIColor(rgb: 0xFFFFFF), UIColor(rgb: 0x795548), UIColor(rgb: 0x727272),
                                UIColor(rgb: 0xB6B6B6)]
    
    static func productCellBgColor() -> UIColor {
        return CELL_BG_COLOR[Int(arc4random_uniform(UInt32(CELL_BG_COLOR.count)))]
    }
}
