//
//  UserProductRelationService.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Result

public enum UserProductRelationServiceError: Printable {
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

public typealias UserProductRelationServiceResult = (Result<UserProductRelation, UserProductRelationServiceError>) -> Void

public protocol UserProductRelationService {
    
    /**
    Retrieves the relation between a user and a product (is favorite and is reported)
    
    :param: userId The user id.
    :param: productId The product id.
    :param: result The completion closure.
    */
    func retrieveUserProductRelationWithId(userId: String, productId: String, result: UserProductRelationServiceResult?)
}