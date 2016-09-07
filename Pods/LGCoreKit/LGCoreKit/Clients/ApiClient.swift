//
//  ApiClient.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Alamofire
import JWT
import Result
import RxSwift
import Argo

protocol ApiClient: class {
    weak var sessionManager: SessionManager? { get }
    weak var installationRepository: InstallationRepository? { get }

    var tokenDAO: TokenDAO { get }

    var renewingInstallation: Bool { get set }
    var installationQueue: NSOperationQueue { get }

    /**
    Executes the given request with a decoder.
    - parameter request: The request.
    - parameter decoder: The decoder.
    - parameter completion: The completion closure.
    */
    func privateRequest<T>(request: URLRequestAuthenticable, decoder: AnyObject -> T?,
        completion: ((ResultResult<T, ApiError>.t) -> ())?)

    /**
    Uploads a file.
    - parameter request: The request.
    - parameter decoder: The decoder.
    - parameter multipart: The multipart encoder.
    - parameter completion: The completion closure.
    - parameter progress: The closure that notifies about the upload progress.
    */
    func upload<T>(request: URLRequestAuthenticable, decoder: AnyObject -> T?,
            multipart: MultipartFormData -> Void, completion: ((ResultResult<T, ApiError>.t) -> ())?,
            progress: ((written: Int64, totalWritten: Int64, totalExpectedToWrite: Int64) -> Void)?)
}

extension ApiClient {

    // MARK: - Internal methods
    
    /**
    Runs a request.
    - parameter req: The request.
    - parameter decoder: The decoder.
    - parameter completion: The completion closure.
    */
    func request<T>(req: URLRequestAuthenticable, decoder: AnyObject -> T?,
                 completion: ((ResultResult<T, ApiError>.t) -> ())?) {
        renewTokenIfNeeded(req,
            succeeded: { [weak self] in
                self?.request(req, decoder: decoder, completion: completion)
            },
            failed: { error in
                completion?(ResultResult<T, ApiError>.t(error: error))
            },
            notNeeded: { [weak self] in
                self?.privateRequest(req, decoder: decoder, completion: completion)
            })
    }
    
    /**
    Runs a request.
    - parameter req: The request.
    - parameter decoder: The decoder.
    - parameter completion: The completion closure.
    */
    func request(req: URLRequestAuthenticable, completion: ((ResultResult<Void, ApiError>.t) -> ())?) {
        request(req, decoder: { object in return Void() }, completion: completion)
    }
    
    /**
    Handles the private request response.
    - parameter request: The request.
    - parameter response: The response.
    - parameter completion: The completion closure.
    */
    func handlePrivateApiErrorResponse<T>(request: URLRequestAuthenticable, response: Response<T, NSError>,
        completion: ((ResultResult<T, ApiError>.t) -> ())?) {
            if let error = errorFromAlamofireResponse(response) {
                let loggingType: CoreLoggingOptions
                switch error {
                case .Unauthorized:
                    loggingType = [CoreLoggingOptions.Networking, CoreLoggingOptions.Token]
                case .Scammer, .NotFound, .Forbidden, .Conflict, .UnprocessableEntity, .InternalServerError,
                     .Network, .Internal, .NotModified, .TooManyRequests, .UserNotVerified, .Other:
                    loggingType = [CoreLoggingOptions.Networking]
                }
                logMessage(.Verbose, type: loggingType, message: response.logMessage)

                handlePrivateApiErrorResponse(error, response: response)
                completion?(ResultResult<T, ApiError>.t(error: error))
            } else if let value = response.result.value {
                logMessage(.Info, type: CoreLoggingOptions.Networking, message: response.logMessage)

                updateToken(response)
                completion?(ResultResult<T, ApiError>.t(value: value))
            }
    }
    
    /**
    Returns an `ApiError` from the given response.
    - parameter response: The request response.
    - returns An `ApiError`.
    */
    func errorFromAlamofireResponse<T>(response: Response<T, NSError>) -> ApiError? {
        guard let error = response.result.error else { return nil }
        if error.domain == NSURLErrorDomain {
            return .Network(errorCode: error.code)
        } else if let statusCode = response.response?.statusCode {
            return ApiError.errorForCode(statusCode, apiCode: response.apiErrorCode)
        } else {
            return ApiError.Internal(description: error.description)
        }
    }
    
    
    // MARK: - Private methods

    /**
    Renews a token if needed. If a request requires an installation it might create it.
     - parameter succeeded:  Completion closure executed after renewing a token.
     - parameter failed:     Completion closure executed when token renew failed
                             or the required auth level is higher than required.
     - parameter notNeeded:  Completion closure executed when token renew is not needed.
     */
    private func renewTokenIfNeeded(request: URLRequestAuthenticable, succeeded: (() -> ())?,
                                    failed: ((ApiError) -> ())?, notNeeded: (() -> ())?) {
        if tokenDAO.level == .None && request.requiredAuthLevel > .None {
            renewInstallationTokenIfNeeded(request, succeeded: succeeded, failed: failed, notNeeded: notNeeded)
        }
        else if request.requiredAuthLevel > tokenDAO.level {
            failed?(.Unauthorized)
            report(CoreReportSession.InsufficientTokenLevel,
                   message: "required auth level: \(request.requiredAuthLevel); current level: \(tokenDAO.level)")
        } else {
            notNeeded?()
        }
    }

    /**
     Renews a token if needed. If a request requires an installation it might create/authenticate it.

     - parameter succeeded:  Completion closure executed after Installation token auth/creation.
     - parameter failed:     Completion closure executed when Installation token auth/creation failed
     or the required auth level is higher than required.
     - parameter notNeeded:  Completion closure executed when token renew is not needed.
     */
    private func renewInstallationTokenIfNeeded(request: URLRequestAuthenticable, succeeded: (() -> ())?,
                                                failed: ((ApiError) -> ())?, notNeeded: (() -> ())?) {
        if !renewingInstallation {
            renewingInstallation = true
            installationQueue.suspended = true

            sessionManager?.authenticateInstallation { [weak self] result in
                guard let strongSelf = self else { return }

                if let _ = result.value {
                    succeeded?()
                } else if let error = result.error {
                    failed?(error)
                }
                strongSelf.renewingInstallation = false
                strongSelf.installationQueue.suspended = false
            }
        } else {
            installationQueue.addOperationWithBlock { [weak self] in
                guard let strongSelf = self else { return }
                dispatch_async(dispatch_get_main_queue()) {
                    if strongSelf.tokenDAO.level > .None {
                        succeeded?()
                    } else {
                        failed?(.Unauthorized)
                    }
                }
            }
        }
    }

    /**
    Handles an API error deleting the `Installation` if unauthorized or logging out the current user if scammer.
    - parameter error: The API error.
    */
    private func handlePrivateApiErrorResponse<T>(error: ApiError, response: Response<T, NSError>) {
        let currentLevel = tokenDAO.level
        switch error {
        case .Unauthorized:
            switch currentLevel {
            case .None:
                break
            case .User:
                sessionManager?.tearDownSession(kicked: true)
            case .Installation:
                // Erase installation and all tokens 
                installationRepository?.delete()
                tokenDAO.reset()
            }
        case .Scammer:
            // If scammer then force logout
            sessionManager?.tearDownSession(kicked: true)
        case .NotFound, .Conflict, .InternalServerError, .UnprocessableEntity, .UserNotVerified, .Other, .Network,
             .Internal, .NotModified, .Forbidden, .TooManyRequests:
            break
        }

        if let networkReport = CoreReportNetworking(apiError: error, currentAuthLevel: currentLevel) {
            report(networkReport, message: response.logMessage)
        }
    }

    /**
    Updates the token with the given request response.
    - parameter response: The request response.
    */
    private func updateToken<T>(response: Response<T, NSError>) {
        guard let token = decodeToken(response) else { return }
        if let sessionManager = sessionManager where token.level == .User && !sessionManager.loggedIn {
            logMessage(.Error, type: [CoreLoggingOptions.Networking, CoreLoggingOptions.Token],
                message: "Received user token and the user is not logged in")
            return
        }
        tokenDAO.save(token)
    }
    
    /**
    Decodes the given response and returns a token.
    - parameter response: The request response.
    - returns: The token with value as `"Bearer <token>"`.
    */
    private func decodeToken<T>(response: Response<T, NSError>) -> Token? {
        guard let authenticationInfo = response.response?.allHeaderFields["authentication-info"] as? String else {
            return nil
        }
        guard let token = authenticationInfo.componentsSeparatedByString(" ").last,
            payload = try? JWT.decode(token, algorithm: .HS256(""), verify: false),
            data = payload["data"] as? [String: AnyObject],
            roles = data["roles"] as? [String] else {
                logMessage(.Error, type: [CoreLoggingOptions.Networking, CoreLoggingOptions.Token],
                    message: "Invalid JWT; authentication-info: \(authenticationInfo)")
                report(CoreReportNetworking.InvalidJWT, message: "authentication-info: \(authenticationInfo)")
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


extension Response {
    var apiErrorCode: Int? {
        guard let data = self.data where data.length > 0 else { return nil }
        guard let value = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else { return nil }
        let code: LGApiErrorCode? = decode(value)
        guard let codeString = code?.code else { return nil }
        return Int(codeString)
    }
}
