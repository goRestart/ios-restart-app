//
//  UserProduct.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 26/01/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation


public protocol UserProduct: BaseModel {
    var name: String? { get }
    var avatar: File? { get }
    var postalAddress: PostalAddress { get }
    
    var status: UserStatus { get }
    
    var banned: Bool? { get }
    var isDummy: Bool { get }
}
