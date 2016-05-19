//
//  Sticker.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol Sticker: UserDefaultsDecodable {
    var url: String { get }
    var name: String { get }
}
