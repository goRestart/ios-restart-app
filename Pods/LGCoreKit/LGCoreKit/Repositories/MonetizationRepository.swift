//
//  MonetizationRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 27/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias BumpeableProductResult = Result<BumpeableProduct, RepositoryError>
public typealias BumpeableProductCompletion = (BumpeableProductResult) -> Void

public protocol MonetizationRepository {
    func retrieveBumpeableProductInfo(productId: String, completion: BumpeableProductCompletion?)
}
