//
//  ProductListModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 30/6/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum ProductListModel {
    case Product(data: ProductData)
    case Banner(data: BannerData)
}

struct ProductData {
    var title: String
}

struct BannerData {
    var title: String
}
