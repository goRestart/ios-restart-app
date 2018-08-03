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
    static var acceptHeader: String? { get }
    static var contentTypeHeader: String? { get }
}

struct APIBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.apiBaseURL
    static let acceptHeader: String? = "application/json;version=2"
    static let contentTypeHeader: String? = nil
}

struct RealEstateBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.realEstateBaseURL
    static let acceptHeader: String? = "application/json"
    static let contentTypeHeader: String? = nil
}

struct ServicesBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.servicesBaseURL
    static let acceptHeader: String? = "application/json"
    static let contentTypeHeader: String? = nil
}

struct SearchServicesBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.searchServicesBaseURL
    static let acceptHeader: String? = "application/json"
    static let contentTypeHeader: String? = nil
}

struct CarsBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.carsBaseURL
    static let acceptHeader: String? = "application/json"
    static let contentTypeHeader: String? = nil
}

struct SearchRealEstateBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.searchRealEstateBaseURL
    static let acceptHeader: String? = "application/json"
    static let contentTypeHeader: String? = nil
}

struct SearchCarsBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.searchCarsBaseURL
    static let acceptHeader: String? = "application/json"
    static let contentTypeHeader: String? = nil
}

struct BouncerBaseURL: BaseURL {
    static var baseURL: String = EnvironmentProxy.sharedInstance.bouncerBaseURL
    static let acceptHeader: String? = "application/vnd.letgo-api+json;version=2"
    static let contentTypeHeader: String? = "application/vnd.letgo-api+json;version=2"
}

struct ChatBaseURL: BaseURL {
    static var baseURL: String = EnvironmentProxy.sharedInstance.chatBaseURL
    static let acceptHeader: String? = nil
    static let contentTypeHeader: String? = nil
}

struct UserRatingsBaseURL: BaseURL {
    static var baseURL: String = EnvironmentProxy.sharedInstance.userRatingsBaseURL
    static let acceptHeader: String? = nil
    static let contentTypeHeader: String? = nil
}

struct NotificationsBaseURL: BaseURL {
    static var baseURL: String = EnvironmentProxy.sharedInstance.notificationsBaseURL
    static let acceptHeader: String? = nil
    static let contentTypeHeader: String? = nil
}

struct PaymentsBaseURL: BaseURL {
    static var baseURL: String = EnvironmentProxy.sharedInstance.paymentsBaseURL
    static let acceptHeader: String? = nil
    static let contentTypeHeader: String? = nil
}

struct SuggestiveSearchBaseURL: BaseURL {
    static var baseURL: String = EnvironmentProxy.sharedInstance.suggestiveSearchBaseURL
    static let acceptHeader: String? = nil
    static let contentTypeHeader: String? = nil
}

struct SearchProductsBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.searchProductsBaseURL
    static let acceptHeader: String? = "application/json;version=2"
    static let contentTypeHeader: String? = nil
}

struct NiordBaseURL: BaseURL {
    static var baseURL: String = EnvironmentProxy.sharedInstance.niordBaseURL
    static let acceptHeader: String? = nil
    static let contentTypeHeader: String? = nil
}

struct SpellCorrectorBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.spellCorrectorBaseURL
    static let acceptHeader: String? = "application/json;version=2"
    static let contentTypeHeader: String? = nil
}

struct MeetingsBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.meetingsBaseURL
    static let acceptHeader: String? = "application/json"
    static let contentTypeHeader: String? = nil
}

struct SearchAlertsBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.searchAlertsBaseURL
    static let acceptHeader: String? = "application/json"
    static let contentTypeHeader: String? = "application/json"
}

struct CustomFeedBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.customFeedBaseURL
    static let acceptHeader: String? = "application/json;version=2"
    static let contentTypeHeader: String? = nil
}

struct NotificationSettingsPusherBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.notificationSettingsPusherBaseURL
    static let acceptHeader: String? = "application/json"
    static let contentTypeHeader: String? = "application/json"
}

struct NotificationSettingsMailerBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.notificationSettingsMailerBaseURL
    static let acceptHeader: String? = "application/json"
    static let contentTypeHeader: String? = "application/json"
}

struct ReportingBaseURL: BaseURL {
    static let baseURL = EnvironmentProxy.sharedInstance.reportingBaseURL
    static let acceptHeader: String? = "application/vnd.api+json;version=1"
    static let contentTypeHeader: String? = "application/vnd.api+json;version=1"
}

enum Encoding {
    case json, url
}

enum Router<T: BaseURL>: URLRequestConvertible {

    case index(endpoint: String, params: [String : Any])
    case show(endpoint: String, objectId: String)
    case create(endpoint: String, params: [String : Any], encoding: Encoding?)
    case batchCreate(endpoint: String, params: Any)
    case update(endpoint: String, objectId: String?, params: [String : Any], encoding: Encoding?)
    case batchUpdate(endpoint: String, params: [String : Any], encoding: Encoding?)
    case patch(endpoint: String, objectId: String, params: [String : Any], encoding: Encoding?)
    case batchPatch(endpoint: String, params: [String : Any], encoding: Encoding?)
    case delete(endpoint: String, objectId: String)
    case batchDelete(endpoint: String, params: Any, encoding: Encoding?)
    case read(endpoint: String, params: [String: Any])

    var method: Alamofire.HTTPMethod {
        switch self {
        case .create, .batchCreate:
            return .post
        case .index, .show, .read:
            return .get
        case .update, .batchUpdate:
            return .put
        case .patch, .batchPatch:
            return .patch
        case .delete, .batchDelete:
            return .delete
        }
    }
    
    var paramEncoding: Encoding {
        switch self {
        case .index, .read, .show, .delete:
            return .url
        case let .create(_, _, encoding):
            return encoding ?? .json
        case .batchCreate:
            return .json
        case let .update(_, _, _, encoding):
            return encoding ?? .json
        case let .batchUpdate(_, _, encoding):
            return encoding ?? .json
        case let .patch(_, _, _, encoding):
            return encoding ?? .json
        case let .batchPatch(_, _, encoding):
            return encoding ?? .json
        case let .batchDelete(_, _, encoding):
            return encoding ?? .json
        }
    }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        switch paramEncoding {
        case .url:
            return try Alamofire.URLEncoding().encode(urlRequest, with: parameters)
        case .json:
            return try Alamofire.JSONEncoding().encode(urlRequest, with: parameters)
        }
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, withJSONObject jsonObject: Any? = nil) throws -> URLRequest {
        return try Alamofire.JSONEncoding().encode(urlRequest, withJSONObject: jsonObject)
    }

    func asURLRequest() throws -> URLRequest {
        guard let baseUrl = URL(string: T.baseURL) else { throw ApiError.internalError(description: "") }
        var urlRequest = URLRequest(url: baseUrl)
        urlRequest.httpMethod = method.rawValue
        
        if let token = InternalCore.tokenDAO.value {
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case let .read(endpoint, params):
            urlRequest.url = baseUrl.appendingPathComponent(endpoint)
            urlRequest = try encode(urlRequest, with: params)
        case let .index(endpoint, params):
            urlRequest.url = baseUrl.appendingPathComponent(endpoint)
            urlRequest = try encode(urlRequest, with: params)
        case let .show(endpoint, objectId):
            urlRequest.url = baseUrl.appendingPathComponent(endpoint).appendingPathComponent(objectId)
        case let .create(endpoint, params, _):
            urlRequest.url = baseUrl.appendingPathComponent(endpoint)
            urlRequest = try encode(urlRequest, with: params)
        case let .batchCreate(endpoint, jsonObject):
            urlRequest.url = baseUrl.appendingPathComponent(endpoint)
            urlRequest = try encode(urlRequest, withJSONObject: jsonObject)
        case let .update(endpoint, objectId, params, _):
            var url = baseUrl.appendingPathComponent(endpoint)
            if let objectId = objectId {
                url = url.appendingPathComponent(objectId)
            }
            urlRequest.url = url
            urlRequest = try encode(urlRequest, with: params)
        case let .batchUpdate(endpoint, params, _):
            urlRequest.url = baseUrl.appendingPathComponent(endpoint)
            urlRequest = try encode(urlRequest, with: params)
        case let .patch(endpoint, objectId, params, _):
            urlRequest.url = baseUrl.appendingPathComponent(endpoint).appendingPathComponent(objectId)
            urlRequest = try encode(urlRequest, with: params)
        case let .batchPatch(endpoint, params, _):
            urlRequest.url = baseUrl.appendingPathComponent(endpoint)
            urlRequest = try encode(urlRequest, with: params)
        case let .delete(endpoint, objectId):
            urlRequest.url = baseUrl.appendingPathComponent(endpoint).appendingPathComponent(objectId)
        case let .batchDelete(endpoint, jsonObject, _):
            urlRequest.url = baseUrl.appendingPathComponent(endpoint)
            urlRequest = try encode(urlRequest, withJSONObject: jsonObject)
        }
        
        // When calling `paramEncoding.encode` the Content-Type Header is setted automatically to the correct value
        // JSON is a special case. The defaul value would be `application/json` but we need to override it for some of
        // our apis
        switch paramEncoding {
        case .json:
            if let contentType = T.contentTypeHeader {
                urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            }
        default:
            break
        }
        // All the responses will always be of type JSON, when calling the Bouncer API we need to set the
        // `Accept` Header to our custom JSON format. By default, the Accept Header is `application/json`
        if let accept = T.acceptHeader {
            urlRequest.setValue(accept, forHTTPHeaderField: "Accept")
        }
        return urlRequest
    }
}

