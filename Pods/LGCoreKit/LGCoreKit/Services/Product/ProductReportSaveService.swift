//
//  ProductReportSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum ProductReportSaveServiceError: ErrorType, CustomStringConvertible {
    case Network
    case AlreadyExists
    case Internal
    case Forbidden
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case AlreadyExists:
            return "AlreadyExists"
        case Internal:
            return "Internal"
        case Forbidden:
            return "Forbidden"
        }
    }
    
    init(apiError: ApiError) {
        switch apiError {
        case .Internal, .Unauthorized, .NotFound, .AlreadyExists, .InternalServerError:
            self = .Internal
        case .Network:
            self = .Network
        case .Scammer:
            self = .Forbidden
        }
    }
}

public typealias ProductReportSaveServiceResult = Result<Nil, ProductReportSaveServiceError>
public typealias ProductReportSaveServiceCompletion = ProductReportSaveServiceResult -> Void

public protocol ProductReportSaveService {
    
    /**
        Reports a product.
    
        - parameter product: the product.
        - parameter user: the reporter user.
        - parameter completion: The completion closure.
    */
    func saveReportProduct(product: Product, user: User, sessionToken: String, completion: ProductReportSaveServiceCompletion?)
}