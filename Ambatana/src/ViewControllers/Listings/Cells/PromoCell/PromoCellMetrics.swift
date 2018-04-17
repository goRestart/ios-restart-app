//
//  PromoCellMetrics.swift
//  LetGo
//
//  Created by Tomas Cobo on 06/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//


struct PromoCellMetrics {
    
    static let height: CGFloat = 230
    
    struct Stack {
        static let margin: CGFloat = Metrics.margin
        static let bottomMargin: CGFloat = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus) ? Metrics.shortMargin :
            Metrics.margin
    }
    
    struct Title {
        static let font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
    }
    
    struct PostButton {
        static let height: CGFloat = 30
        static let width: CGFloat = 90
    }
}
