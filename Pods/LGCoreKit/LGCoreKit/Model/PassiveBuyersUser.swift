//
//  PassiveBuyersUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol PassiveBuyersUser: BaseModel {
    var name: String? { get }
    var avatar: File? { get }
}
