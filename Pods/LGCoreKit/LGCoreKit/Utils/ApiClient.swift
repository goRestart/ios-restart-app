//
//  ApiClient.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 02/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result


public enum ApiError: ErrorType {
    case Network
    case Internal
    
    case Unauthorized
    case NotFound
    case AlreadyExists
    case Scammer
    case InternalServerError
        
    
    static func errorForCode(code: Int) -> ApiError {
        switch code {
        case 400:   // Bad request is our fault
            return .Internal
        case 401:   // Wrong credentials
            return .Unauthorized
        case 403:   // Forbidden is our fault
            return .Unauthorized
        case 404:
            return .NotFound
        case 409:   // Conflict
            return .AlreadyExists
        case 418:   // I'm a teapot! 🍵
            return .Scammer
        case 500..<600:
            return .InternalServerError
        default:
            return .Internal
        }
    }
}

enum AuthLevel: Int {
    case None
    case Installation
    case User
}

protocol URLRequestAuthenticable: URLRequestConvertible {
    var requiredAuthLevel: AuthLevel { get }
    // Minimum received auth level from the response. Doesn't mean the actual received auth level.
    var minReceivedAuthLevel: AuthLevel { get }
}

extension URLRequestAuthenticable {
    var minReceivedAuthLevel: AuthLevel {
        return requiredAuthLevel
    }
}

class ApiClient {
    
    static let tokenDAO: TokenDAO = TokenKeychainDAO.sharedInstance
    
    static func request<T>(request: URLRequestAuthenticable, decoder: AnyObject -> T?,
        completion: ((ResultResult<T, ApiError>.t) -> ())?) {

            createInstallationIfNeeded(request, success: {
                ApiClient.request(request, decoder: decoder, completion: completion)
            }, completion: { result in
                if let _ = result.value {
                    privateRequest(request, decoder: decoder, completion: completion)
                } else if let error = result.error {
                    completion?(ResultResult<T, ApiError>.t(error: error))
                }
            })
    }

    static func upload<T>(request: URLRequestAuthenticable, decoder: AnyObject -> T?,
        multipart: MultipartFormData -> Void, completion: ((ResultResult<T, ApiError>.t) -> ())?,
        progress: ((written: Int64, totalWritten: Int64, totalExpectedToWrite: Int64) -> Void)? = nil) {

            guard request.requiredAuthLevel <= tokenDAO.level else {
                completion?(ResultResult<T, ApiError>.t(error: .Unauthorized))
                return
            }
            
            Alamofire.upload(request, multipartFormData: multipart) { result in
                
                switch result {
                case let .Success(upload, _, _):
                    upload.validate(statusCode: 200..<400)
                        .responseObject(decoder) { (response: Response<T, NSError>) in
                            if let actualError = errorFromAlamofireResponse(response) {
                                completion?(ResultResult<T, ApiError>.t(error: actualError))
                            } else if let uploadFileResponse = response.result.value {
                                completion?(ResultResult<T, ApiError>.t(value: uploadFileResponse))
                            }
                        }.progress(progress)
                case .Failure(_):
                    completion?(ResultResult<T, ApiError>.t(error: .Internal))
                }
            }
    }
    
    
    // MARK: - Private methods
    
    private static func createInstallationIfNeeded(request: URLRequestAuthenticable,
        success: (() -> ())?,
        completion: ((ResultResult<Void, ApiError>.t) -> ())?) {
            
            if tokenDAO.level == .None && request.requiredAuthLevel > .None {
                InstallationRepository.sharedInstance.create { result in
                    if let _ = result.value {
                        success?()
                    } else if let error = result.error {
                        completion?(ResultResult<Void, ApiError>.t(error: error))
                    }
                }
            } else if request.requiredAuthLevel > tokenDAO.level {
                completion?(ResultResult<Void, ApiError>.t(error: .Unauthorized))
            } else {
                completion?(ResultResult<Void, ApiError>.t(value: Void()))
            }
    }
    
    private static func privateRequest<T>(request: URLRequestAuthenticable,
        decoder: AnyObject -> T?, completion: ((ResultResult<T, ApiError>.t) -> ())?) {
            Manager.validatedRequest(request).responseObject(decoder) { (response: Response<T, NSError>) in
                    let value = response.result.value
                    handlePrivateResponse(request, response: response, value: value, completion: completion)
            }
    }
    
    private static func handlePrivateResponse<T, U>(request: URLRequestAuthenticable, response: Response<T, NSError>, 
        value: U?, completion: ((ResultResult<U, ApiError>.t) -> ())?) {        
            if let error = errorFromAlamofireResponse(response) {
                handlePrivateApiErrorResponse(request, error: error, completion: completion)
            } else if let value = value {
                upgradeTokenIfNeeded(request, response: response, value: value, completion: completion)
            }
    }
    
    private static func errorFromAlamofireResponse<T>(response: Response<T, NSError>) -> ApiError? {
        guard let error = response.result.error else { return nil }
        if error.domain == NSURLErrorDomain {
            return .Network
        } else if let statusCode = response.response?.statusCode {
            return ApiError.errorForCode(statusCode)
        } else {
            return .Internal
        }
    }
    
    private static func handlePrivateApiErrorResponse<T>(request: URLRequestAuthenticable, error: ApiError,
        completion: ((ResultResult<T, ApiError>.t) -> ())?) {
            
            switch error {
            case .Unauthorized:
                let currentLevel = tokenDAO.level
                
                switch currentLevel {
                case .None, .User:
                    break
                case .Installation:
                    // Erase installation and all tokens
                    InstallationRepository.sharedInstance.delete()
                    tokenDAO.reset()
                }
            case .Scammer:
                // If scammer then logout
                SessionManager.sharedInstance.logout()
            case .Network, .Internal, .NotFound, .AlreadyExists, .InternalServerError:
                break
            }
            
            completion?(ResultResult<T, ApiError>.t(error: error))
    }
    
    private static func upgradeTokenIfNeeded<T, U>(request: URLRequestAuthenticable,
        response: Response<T, NSError>, value: U, completion: ((ResultResult<U, ApiError>.t) -> ())?) {
            
            let currentLevel = tokenDAO.level
            if let token = response.response?.allHeaderFields["authentication-info"] as? String {
                let minReceivedLevel = request.minReceivedAuthLevel
                if minReceivedLevel >= currentLevel {
                    tokenDAO.save(Token(value: token, level: minReceivedLevel))
                }
            }
            completion?(ResultResult<U, ApiError>.t(value: value))
    }
    
}
