//
//  PassiveBuyersInfo.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol PassiveBuyersInfo: BaseModel {
    var productImage: File? { get }
    var passiveBuyers: [PassiveBuyersUser] { get }
}
