//
//  LGError.swift
//  LGCoreKit
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public enum LGErrorCode: Int {
    case Internal, Parsing
    case SessionExpired, UnexpectedServerResponse
    case Network
}

extension NSError {
    public static var LGErrorDomain: String {
        get {
            return "com.letgo.ios"
        }
    }
    
    public convenience init(code: LGErrorCode) {
        self.init(domain: NSError.LGErrorDomain, code: code.rawValue, userInfo: nil)
    }
}