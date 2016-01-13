//
//  ApiClient.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 02/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import JWT
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
}


class ApiClient {

    static let tokenDAO: TokenDAO = TokenKeychainDAO.sharedInstance

    
    // MARK: - Internal methods
    
    /**
    Runs a request.
    - parameter request: The request.
    - parameter decoder: The decoder.
    - parameter completion: The completion closure.
    */
    static func request<T>(request: URLRequestAuthenticable, decoder: AnyObject -> T?,
        completion: ((ResultResult<T, ApiError>.t) -> ())?) {

            createInstallationIfNeeded(request,
                createSucceeded: {
                    ApiClient.request(request, decoder: decoder, completion: completion)
                },
                failed: { error in
                    completion?(ResultResult<T, ApiError>.t(error: error))
                },
                createNotNeeded: {
                    privateRequest(request, decoder: decoder, completion: completion)
                }
            )
    }

    /**
    Uploads a file.
    - parameter request: The request.
    - parameter decoder: The decoder.
    - parameter multipart: The multipart encoder.
    - parameter completion: The completion closure.
    - parameter progress: The closure that notifies about the upload progress.
    */
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

    /**
    Creates an installation if the request requires installation token and we do not have it.
    - parameter createSucceeded: Completion closure executed when the installation is created successfully.
    - parameter failed: Completion closure executed when the installation creation fails or the required auth level is
                        higher than required.
    - parameter createNotNeeded: Completion closure executed when the installation creation is not needed.
    */
    private static func createInstallationIfNeeded(request: URLRequestAuthenticable, createSucceeded: (() -> ())?,
        failed: ((ApiError) -> ())?, createNotNeeded: (() -> ())?) {
            
            if tokenDAO.level == .None && request.requiredAuthLevel > .None {
                InstallationRepository.sharedInstance.create { result in
                    if let _ = result.value {
                        createSucceeded?()
                    } else if let error = result.error {
                        failed?(error)
                    }
                }
            } else if request.requiredAuthLevel > tokenDAO.level {
                failed?(.Unauthorized)
            } else {
                createNotNeeded?()
            }
    }

    /**
    Executes the given request with a decoder.
    - parameter request: The request.
    - parameter decoder: The decoder.
    - parameter completion: The completion closure.
    */
    private static func privateRequest<T>(request: URLRequestAuthenticable, decoder: AnyObject -> T?,
        completion: ((ResultResult<T, ApiError>.t) -> ())?) {
            Manager.validatedRequest(request).responseObject(decoder) { (response: Response<T, NSError>) in
                handlePrivateResponse(request, response: response, completion: completion)
            }
    }

    /**
    Handles the private request response.
    - parameter request: The request.
    - parameter response: The response.
    - parameter completion: The completion closure.
    */
    private static func handlePrivateResponse<T>(request: URLRequestAuthenticable, response: Response<T, NSError>,
        completion: ((ResultResult<T, ApiError>.t) -> ())?) {
            if let error = errorFromAlamofireResponse(response) {
                handlePrivateApiErrorResponse(error)
                completion?(ResultResult<T, ApiError>.t(error: error))
            } else if let value = response.result.value {
                updateToken(response)
                completion?(ResultResult<T, ApiError>.t(value: value))
            }
    }

    /**
    Returns an `ApiError` from the given response.
    - parameter response: The request response.
    - returns An `ApiError`.
    */
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

    /**
    Handles an API error deleting the `Installation` if unauthorized or logging out the current user if scammer.
    - parameter error: The API error.
    */
    private static func handlePrivateApiErrorResponse(error: ApiError) {

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
    }

    /**
    Updates the token with the given request response.
    - parameter response: The request response.
    */
    private static func updateToken<T>(response: Response<T, NSError>) {
        guard let token = decodeToken(response) else { return }
        tokenDAO.save(token)
    }
    
    /**
    Decodes the given response and returns a token.
    - parameter response: The request response.
    - returns: The token with value as `"Bearer <token>"`.
    */
    private static func decodeToken<T>(response: Response<T, NSError>) -> Token? {
        guard let authenticationInfo = response.response?.allHeaderFields["authentication-info"] as? String,
                  token = authenticationInfo.componentsSeparatedByString(" ").last,
                  payload = try? JWT.decode(token, algorithm: .HS256(""), verify: false),
                  data = payload["data"] as? [String: AnyObject],
                  roles = data["roles"] as? [String] else {
                    return nil
        }
        
        if roles.contains("user") {
            return Token(value: authenticationInfo, level: .User)
        } else if roles.contains("app") {
            return Token(value: authenticationInfo, level: .Installation)
        }
        return nil
    }
}
