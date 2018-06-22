//
//  LGNavBarMetrics.swift
//  LetGo
//
//  Created by Tomas Cobo on 23/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGComponents

struct LGNavBarMetrics {
    struct Size {
        static var navBarSize: CGSize {
            if #available(iOS 11.0, *) {
                return .zero
            } else {
                return CGSize(width: Metrics.screenWidth, height: 44)
            }
        }
    }
    
    struct Container {
        static let height: CGFloat = 30
        static let largeHeight: CGFloat = 34
        static let backgroundColor = UIColor.black.withAlphaComponent(0.07)
    }
    
    struct Searchfield {
        static let font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        static let textColor = UIColor.lightBarTitle
        static let placeHolderTextColor = UIColor(red: 158, green: 158, blue: 158)
        static let clearButtonOffset: CGFloat = 5
        static let insetX: CGFloat = 30
    }
    
    struct Magnifier {
        static let height: CGFloat = 17
        static let width: CGFloat = 17
    }
    
    struct StackView {
        static let verticalDiference: CGFloat = 2
    }
    
    struct Logo {
        static let height: CGFloat = 20
    }
    
    struct GreySearchTextLabel {
        static let height: CGFloat = Logo.height
    }
}
