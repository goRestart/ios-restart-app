//
//  LGNavSearchBoxSize.swift
//  LetGo
//
//  Created by Haiyan Ma on 14/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

enum SearchBoxSize {
    case large, normal
    
    var boxHeight: CGFloat {
        switch self {
        case .large: return LGNavBarMetrics.Container.largeHeight
        case .normal: return LGNavBarMetrics.Container.height
        }
    }
}
