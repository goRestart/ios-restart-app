//
//  LGApiErrorCode.swift
//  LGCoreKit
//
//  Created by Dídac on 30/08/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol ApiProductsErrorCode {
    var code: Int { get }
    var message: String { get }
}

struct LGApiProductsErrorCode: ApiProductsErrorCode, Decodable {
    let code: Int
    let message: String
    
    // MARK: - Decodable
    
    /*
     {
     "code": 11001,
     "message": "Country code for listing sender does not match"
     }
     */
}
