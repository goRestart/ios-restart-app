//
//  ABTests.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

public struct ABTests {
    static var showRelatedProducts = LPVar.define("showRelatedProducts", withBool: false);
    
    static func registerVariables() {
        let _ = showRelatedProducts.boolValue()
    }
}
