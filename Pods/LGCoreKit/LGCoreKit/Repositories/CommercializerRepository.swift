//
//  CommercializerRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias CommercializersResult = Result<[Commercializer], RepositoryError>
public typealias CommercializersCompletion = (CommercializersResult) -> Void

public protocol CommercializerRepository {
    func index(_ productId: String, completion: CommercializersCompletion?)
}
