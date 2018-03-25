//
//  SpellCorretorRouter.swift
//  LGCoreKit
//
//  Created by Tomas Cobo on 14/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

enum SpellCorretorRouter: URLRequestAuthenticable {
    
    private static let relaxBaseUrl = "/relax"
    
    case relaxQuery(searchTerm: String, params: [String: Any])
    
    var requiredAuthLevel: AuthLevel {
        return .nonexistent
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .relaxQuery(_, let params):
            return try Router<SpellCorrectorBaseURL>.index(endpoint: endpoint, params: params).asURLRequest()
        }
    }
    
    private var endpoint: String {
        switch self {
        case let .relaxQuery(searchTerm, _):
            return SpellCorretorRouter.relaxBaseUrl + "/\(searchTerm)"
        }
    }
}
