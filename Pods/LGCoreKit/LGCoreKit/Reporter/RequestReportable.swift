//
//  RequestReportable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/07/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

protocol ReportableRequest {
    var reportingBlacklistedApiError: Array<ApiError> { get }
}
