//
//  UserRepositoryParams.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 27/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

public struct ReportUserParams {
    public var reason: ReportUserReason
    public var comment: String?

    public init(reason: ReportUserReason, comment: String?){
        self.reason = reason
        self.comment = comment
    }
}

public enum ReportUserReason: Int, Equatable {
    case offensive = 1, scammer = 2, mia = 3, suspicious = 4, inactive = 5, prohibitedItems = 6, spammer = 7,
    counterfeitItems = 8, others = 9
}

extension ReportUserParams {
    var reportUserApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()

        params["reason_id"] = reason.rawValue
        params["comment"] = comment

        return params
    }
}
