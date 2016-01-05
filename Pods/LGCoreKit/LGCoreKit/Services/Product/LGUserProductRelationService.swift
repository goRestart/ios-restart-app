//
//  LGUserProductRelationService.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Result
import Argo

final public class LGUserProductRelationService: UserProductRelationService {

    public func retrieveUserProductRelationWithId(userId: String, productId: String,
        completion: UserProductRelationServiceCompletion?) {
        let request = ProductRouter.UserRelation(userId: userId, productId: productId)
        ApiClient.request(request, decoder: LGUserProductRelationService.decoder) {
            (result: Result<UserProductRelation, ApiError>) in
            if let value = result.value {
                completion?(UserProductRelationServiceResult(value: value))
            } else if let error = result.error {
                completion?(UserProductRelationServiceResult(error: UserProductRelationServiceError(apiError: error)))
            }
        }
    }

    static func decoder(object: AnyObject) -> UserProductRelation? {
        let relation: LGUserProductRelation? = decode(object)
        return relation
    }
}