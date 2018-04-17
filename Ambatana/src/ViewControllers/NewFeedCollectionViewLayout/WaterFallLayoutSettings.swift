//
//  WaterFallLayoutSettings.swift
//  LetGo
//
//  Created by Haiyan Ma on 09/04/2018.
//  Copyright © 2018 Haiyan Ma. All rights reserved.
//

import UIKit

struct WaterFallLayoutSettings {

    // Elements sizes
    static let headerHeight: CGFloat = 0
    static let  footerHeight: CGFloat = 0
    static let itemSize: CGSize = CGSize(width: 50, height: 50)
    
    // Behaviours
    static let columnCount: Int = 2
    static let  itemRenderPolicy: WaterfallLayoutItemRenderPolicy = .shortestFirst
    /// If the top header is a super sticky header, it can also be stretchy.
    static let topHeaderIsStretchy: Bool = false
    
    // Spacing
    static let minimumColumnSpacing: CGFloat = 10
    static let minimumLineSpacing: CGFloat = 10
    static let sectionInset: UIEdgeInsets = .zero
}
