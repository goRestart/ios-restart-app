//
//  FileSearchFieldStyle.swift
//  LetGo
//
//  Created by Haiyan Ma on 14/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

enum SearchFieldStyle {
    case letgoRed, grey
    
    var magnifierImage: UIImage { return self == .grey ? #imageLiteral(resourceName: "list_search_grey") :#imageLiteral(resourceName: "list_search") }
    
    var containerCornerRadius: CGFloat {
        switch self {
        case .letgoRed: return LGNavBarMetrics.Container.height / 2.0
        case .grey: return 10
        }
    }
    var imageTextSpacing: CGFloat {
        return self == .letgoRed ? 0 : 8
    }
    
    var shouldHideLetgoIcon: Bool { return self == .grey }
}
