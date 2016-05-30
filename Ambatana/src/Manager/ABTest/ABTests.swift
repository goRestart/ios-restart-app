//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Taplytics

public struct ABTests {
    static var snapchatProductDetail: BoolABDynamicVar {
        return BoolABDynamicVar(key: "snap_product_detail", type: .Bool, defaultValue: false)
    }
    static var chatStickers: BoolABDynamicVar {
        return BoolABDynamicVar(key: "chat_stickers", type: .Bool, defaultValue: false)
    }
    static var mainProducts3Columns: BoolABDynamicVar {
        return BoolABDynamicVar(key: "main_products_3_columns", type: .Bool, defaultValue: false)
    }
}
