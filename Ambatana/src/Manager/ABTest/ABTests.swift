//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Taplytics

public struct ABTests {
    static var mainProducts3Columns: BoolABDynamicVar {
        return BoolABDynamicVar(key: "main_products_3_columns", type: .Bool, defaultValue: false)
    }
    static var productDetailVersion: NumberABDynamicVar {
        return NumberABDynamicVar(key: "product_detail_version", type: .Number, defaultValue: 1)
    }
    static var sellOnStartupAfterPosting: BoolABDynamicVar {
        return BoolABDynamicVar(key: "sell_on_startup_after_posting", type: .Bool, defaultValue: false)
    }
}
