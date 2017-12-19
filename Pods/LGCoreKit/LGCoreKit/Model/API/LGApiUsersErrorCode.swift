//
//  LGApiErrorCode.swift
//  LGCoreKit
//
//  Created by Dídac on 30/08/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol ApiUsersErrorCode {
    var code: String { get }
    var title: String { get }
}

struct LGApiUsersErrorCode: ApiUsersErrorCode, Decodable {
    let code: String
    let title: String
    
    // MARK: Decodable
    
    /*
     {
     "code": "1005",
     "title": "User already exists"
     }
     */
}

