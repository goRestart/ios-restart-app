//
//  ExpressChatViewModel.swift
//  LetGo
//
//  Created by Dídac on 09/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class ExpressChatViewModel: BaseViewModel {

    private var productList: [Product]

    var productListCount: Int {
        return productList.count
    }

    init(productList: [Product]) {
        self.productList = productList
    }

    func imageURLForItemAtIndex(index: Int) -> NSURL {
        guard index < productListCount else { return NSURL() }
        guard let imageUrl = productList[index].thumbnail?.fileURL else { return NSURL() }
        return imageUrl
    }

    func priceForItemAtIndex(index: Int) -> String {
        guard index < productListCount else { return "" }
        return productList[index].priceString()
    }
}