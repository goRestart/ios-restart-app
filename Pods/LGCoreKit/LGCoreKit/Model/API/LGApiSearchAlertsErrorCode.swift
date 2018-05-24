//
//  LGApiSearchAlertsErrorCode.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 23/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

enum SearchAlertsErrorCode: String {
    case alreadyExists = "user-search-alert-already-exists"
    case limitReached = "user-search-alerts-limit-reached"
}

protocol ApiSearchAlertsErrorCode {
    var code: SearchAlertsErrorCode { get }
    var detail: String { get }
}

struct LGApiSearchAlertsErrorCode: ApiSearchAlertsErrorCode, Decodable {
    let code: SearchAlertsErrorCode
    let detail: String
    
    // MARK: - Decodable
    
    /*
     {
     "code": "user-search-alert-already-exists",
     "detail": "User search alert already exists"
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let errorCode = try keyedContainer.decode(String.self, forKey: .code)
        if let code = SearchAlertsErrorCode(rawValue: errorCode) {
            self.code = code
        } else {
            throw DecodingError.valueNotFound(Int.self, DecodingError.Context(codingPath: [CodingKeys.code],
                                                                              debugDescription: "\(errorCode)"))
        }
        detail = try keyedContainer.decode(String.self, forKey: .detail)
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case detail
    }
}
