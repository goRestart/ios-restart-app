//
//  CarsInfo.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//


public protocol CarsInfo {
    var makesList: [CarsMake] { get }
    var others: CarsOthers { get }
}
