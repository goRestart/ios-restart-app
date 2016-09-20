//
//  Sticker.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Argo

public protocol Sticker: UserDefaultsDecodable {
    var url: String { get }
    var name: String { get }
    var type: StickerType { get }
}

public enum StickerType: String {
    case Product = "product"
    case Chat = "chat"
}

extension StickerType: Decodable {}
