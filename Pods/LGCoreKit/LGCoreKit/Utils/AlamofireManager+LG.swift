//
//  AlamofireManager+LG.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 17/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Alamofire

extension Manager {
    static func validatedRequest(req: URLRequestAuthenticable) -> Request {
        return Manager.sharedInstance.request(req).validate(statusCode: 200..<400)
    }
}
