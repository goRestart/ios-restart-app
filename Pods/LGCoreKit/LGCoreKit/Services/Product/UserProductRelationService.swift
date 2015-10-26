//
//  UserProductRelationService.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Result

public enum UserProductRelationServiceError: ErrorType, CustomStringConvertible {
    case Network
    case Internal
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Internal:
            return "Internal"
        }
    }
}

public typealias UserProductRelationServiceResult = Result<UserProductRelation, UserProductRelationServiceError>
public typealias UserProductRelationServiceCompletion = UserProductRelationServiceResult -> Void

public protocol UserProductRelationService {
    
    /**
    Retrieves the relation between a user and a product (is favorite and is reported)
    
    - parameter userId: The user id.
    - parameter productId: The product id.
    - parameter completion: The completion closure.
    */
    func retrieveUserProductRelationWithId(userId: String, productId: String, completion: UserProductRelationServiceCompletion?)
}