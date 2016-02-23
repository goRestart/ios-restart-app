//
//  Router.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 02/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Alamofire


protocol BaseURL {
    static var baseURL: String { get }
}

struct APIBaseURL: BaseURL {
    static var baseURL: String = EnvironmentProxy.sharedInstance.apiBaseURL
}

struct BouncerBaseURL: BaseURL {
    static var baseURL: String = EnvironmentProxy.sharedInstance.bouncerBaseURL
}

enum Encoding {
    case JSON, URL

    var paramEncoding: Alamofire.ParameterEncoding {
        switch self {
        case .URL:
            return Alamofire.ParameterEncoding.URL
        case .JSON:
            return Alamofire.ParameterEncoding.JSON
        }
    }
}

enum Router<T: BaseURL>: URLRequestConvertible {

    case Index(endpoint: String, params: [String : AnyObject])
    case Show(endpoint: String, objectId: String)
    case Create(endpoint: String, params: [String : AnyObject], encoding: Encoding?)
    case BatchCreate(endpoint: String, params: AnyObject)
    case Update(endpoint: String, objectId: String, params: [String : AnyObject], encoding: Encoding?)
    case BatchUpdate(endpoint: String, params: [String : AnyObject], encoding: Encoding?)
    case Patch(endpoint: String, objectId: String, params: [String : AnyObject], encoding: Encoding?)
    case Delete(endpoint: String, objectId: String)
    case BatchDelete(endpoint: String, params: AnyObject, encoding: Encoding?)
    case Read(endpoint: String, params: [String: AnyObject])

    var method: Alamofire.Method {
        switch self {
        case .Create, .BatchCreate:
            return .POST
        case .Index, .Show, .Read:
            return .GET
        case .Update, .BatchUpdate:
            return .PUT
        case .Patch:
            return .PATCH
        case .Delete, .BatchDelete:
            return .DELETE
        }
    }

    var paramEncoding: Alamofire.ParameterEncoding {
        switch self {
        case .Index, .Read, .Show, .Delete:
            return Alamofire.ParameterEncoding.URL
        case let Create(_, _, encoding):
            return encoding?.paramEncoding ?? Alamofire.ParameterEncoding.JSON
        case BatchCreate:
            return Alamofire.ParameterEncoding.JSON
        case let Update(_, _, _, encoding):
            return encoding?.paramEncoding ?? Alamofire.ParameterEncoding.JSON
        case let BatchUpdate(_, _, encoding):
            return encoding?.paramEncoding ?? Alamofire.ParameterEncoding.JSON
        case let Patch(_, _, _, encoding):
            return encoding?.paramEncoding ?? Alamofire.ParameterEncoding.JSON
        case let BatchDelete(_, _, encoding):
            return encoding?.paramEncoding ?? Alamofire.ParameterEncoding.JSON
        }
    }

    var URLRequest: NSMutableURLRequest {

        let baseUrl = NSURL(string: T.baseURL)!
        let mutableURLRequest = NSMutableURLRequest()
        mutableURLRequest.HTTPMethod = method.rawValue

        if let token = InternalCore.dynamicType.tokenDAO.value {
            mutableURLRequest.setValue(token, forHTTPHeaderField: "Authorization")
        }

        var req: NSMutableURLRequest
        switch self {
        case let .Read(endpoint, params):
            mutableURLRequest.URL = baseUrl.URLByAppendingPathComponent(endpoint)
            req = paramEncoding.encode(mutableURLRequest, parameters: params).0
        case let .Index(endpoint, params):
            mutableURLRequest.URL = baseUrl.URLByAppendingPathComponent(endpoint)
            req = paramEncoding.encode(mutableURLRequest, parameters: params).0
        case let .Show(endpoint, objectId):
            mutableURLRequest.URL = baseUrl.URLByAppendingPathComponent(endpoint).URLByAppendingPathComponent(objectId)
            req = mutableURLRequest
        case let .Create(endpoint, params, _):
            mutableURLRequest.URL = baseUrl.URLByAppendingPathComponent(endpoint)
            req = paramEncoding.encode(mutableURLRequest, parameters: params).0
        case let .BatchCreate(endpoint, params):
            mutableURLRequest.URL = baseUrl.URLByAppendingPathComponent(endpoint)
            req = paramEncoding.anyObjectEncode(mutableURLRequest, parameters: params).0
        case let .Update(endpoint, objectId, params, _):
            mutableURLRequest.URL = baseUrl.URLByAppendingPathComponent(endpoint).URLByAppendingPathComponent(objectId)
            req = paramEncoding.encode(mutableURLRequest, parameters: params).0
        case let .BatchUpdate(endpoint, params, _):
            mutableURLRequest.URL = baseUrl.URLByAppendingPathComponent(endpoint)
            req = paramEncoding.encode(mutableURLRequest, parameters: params).0
        case let .Patch(endpoint, objectId, params, _):
            mutableURLRequest.URL = baseUrl.URLByAppendingPathComponent(endpoint).URLByAppendingPathComponent(objectId)
            req = paramEncoding.encode(mutableURLRequest, parameters: params).0
        case let .Delete(endpoint, objectId):
            mutableURLRequest.URL = baseUrl.URLByAppendingPathComponent(endpoint).URLByAppendingPathComponent(objectId)
            req = mutableURLRequest
        case let .BatchDelete(endpoint, params, _):
            mutableURLRequest.URL = baseUrl.URLByAppendingPathComponent(endpoint)
            req = paramEncoding.anyObjectEncode(mutableURLRequest, parameters: params).0
        }


        // When calling `paramEncoding.encode` the Content-Type Header is setted automatically to the correct value
        // JSON is a special case. The defaul value would be `application/json` but we need to override it for our
        // custom value for the Bouncer API (only for Bouncer, not the normal API)
        switch paramEncoding {
        case .JSON:
            if T.baseURL == BouncerBaseURL.baseURL {
                req.setValue("application/vnd.letgo.v1-mobile+json", forHTTPHeaderField: "Content-Type")
            }
        default:
            break
        }


        // All the responses will always be of type JSON, when calling the Bouncer API we need to set the
        // `Accept` Header to our custom JSON format.
        // By default, the Accept Header is `application/json`
        if T.baseURL == BouncerBaseURL.baseURL {
            req.setValue("application/vnd.letgo.v1-mobile+json", forHTTPHeaderField: "Accept")
        }

        return req
    }
}

