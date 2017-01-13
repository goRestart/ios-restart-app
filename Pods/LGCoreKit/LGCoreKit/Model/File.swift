//
//  File.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol File : BaseModel {
    var fileURL: URL? { get }
}
