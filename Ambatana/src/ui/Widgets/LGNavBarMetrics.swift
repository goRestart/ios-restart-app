//
//  LGNavBarMetrics.swift
//  LetGo
//
//  Created by Tomas Cobo on 23/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

struct LGNavBarMetrics {
    struct Container {
        static let height: CGFloat = 30
        static let backgroundColor = UIColor.black.withAlphaComponent(0.07)
    }
    struct Searchfield {
        static let font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        static let textColor = UIColor.lightBarTitle
        static let clearButtonOffset: CGFloat = 5
        static let insetX: CGFloat = 30
    }
    struct Magnifier {
        static let height: CGFloat = 15
        static let width: CGFloat = 15
    }
    
    struct StackView {
        static let verticalDiference: CGFloat = 2
    }
    struct Logo {
        static let height: CGFloat = 20
    }
}
