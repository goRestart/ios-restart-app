//
//  PassiveBuyersRepository.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

public typealias PassiveBuyersResult = Result<PassiveBuyersInfo, RepositoryError>
public typealias PassiveBuyersCompletion = PassiveBuyersResult -> Void

public protocol PassiveBuyersRepository {
    /**
     Retrieves a product passive buyers info.
     
     - parameter productId:     The product id
     - parameter completion:    The completion closure
    */
    func show(productId productId: String, completion: PassiveBuyersCompletion?)

    /**
     Contacts all potential buyers for a given product passive buyers info.

     - parameter passiveBuyersInfo: The passive buyers info
     - parameter completion:        The completion closure
     */
    func contactAllBuyers(passiveBuyersInfo passiveBuyersInfo: PassiveBuyersInfo, completion: (Result<Void, RepositoryError> -> ())?)
}
