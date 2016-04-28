//
//  NSError+LG.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum ErrorCode: Int {
    case ImageDownloadFailed
}

extension NSError {
    convenience init(code: ErrorCode) {
        self.init(domain: Constants.appDomain, code: code.rawValue, userInfo: nil)
    }
}