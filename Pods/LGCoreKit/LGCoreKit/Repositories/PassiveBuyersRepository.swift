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
public typealias PassiveBuyersCompletion = (PassiveBuyersResult) -> Void

public typealias PassiveBuyersEmptyResult = Result<Void, RepositoryError>
public typealias PassiveBuyersEmptyCompletion = (PassiveBuyersEmptyResult) -> Void

public protocol PassiveBuyersRepository {
    /**
     Retrieves a listing passive buyers info.
     
     - parameter listingId:     The listing id
     - parameter completion:    The completion closure
    */
    func show(listingId: String, completion: PassiveBuyersCompletion?)

    /**
     Contacts all potential buyers for a given listing passive buyers info.

     - parameter passiveBuyersInfo: The passive buyers info
     - parameter completion:        The completion closure
     */
    func contactAllBuyers(passiveBuyersInfo: PassiveBuyersInfo, completion: PassiveBuyersEmptyCompletion?)
}
