//
//  LGAuthentication.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 17/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

protocol Authentication {
    var id: String { get }
    var token: String { get }
}

struct LGAuthentication: Authentication, Decodable {
    let id: String
    let token: String
    
    // MARK: Decodable
    
    /*
     {
     "id": "string",
     "auth_token": "string"
     }
     */
    
    enum CodingKeys: String, CodingKey {
        case id
        case token = "auth_token"
    }
}
