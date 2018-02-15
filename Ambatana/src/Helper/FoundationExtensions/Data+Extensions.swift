//
//  Data+Extensions.swift
//  LetGo
//
//  Created by Nestor on 30/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}
