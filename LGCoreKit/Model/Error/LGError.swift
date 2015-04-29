//
//  LGError.swift
//  LGCoreKit
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import UIKit

public enum LGInternalErrorCode {
    case Parsing, Unexpected
}

public enum LGServerErrorCode {
    case Session, Unexpected
}

public enum LGErrorType: Equatable {
    case Internal(LGInternalErrorCode)
    case Server(LGServerErrorCode)
    case Network
}

public struct LGError: Equatable {
    let type: LGErrorType
    let explanation: String
    
    public init(type: LGErrorType, explanation: String = "") {
        self.type = type
        self.explanation = explanation
    }
}

// MARK: Equatable

public func ==(lhs: LGErrorType, rhs: LGErrorType) -> Bool {
    return lhs == rhs
}

public func ==(lhs: LGError, rhs: LGError) -> Bool {
    return lhs.type == rhs.type
}