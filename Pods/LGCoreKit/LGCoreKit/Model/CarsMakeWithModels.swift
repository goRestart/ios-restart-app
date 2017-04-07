//
//  CarsMakeWithModels.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol CarsMakeWithModels {
    var makeId: String { get }
    var makeName: String { get }
    var models: [CarsModel] { get }
}
