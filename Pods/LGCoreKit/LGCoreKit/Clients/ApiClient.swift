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

    var renewingUser: Variable<Bool> { get }
    var userQueue: NSOperationQueue { get }

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


// MARK: - Internal methods

extension ApiClient {
    /**
    Runs a request.
    - parameter req:        The request.
    - parameter decoder:    The decoder.
    - parameter completion: The completion closure.
    */
    func request<T>(req: URLRequestAuthenticable, decoder: AnyObject -> T?,
                 completion: ((ResultResult<T, ApiError>.t) -> ())?) {
        renewTokenIfNeeded(req, decoder: decoder, succeeded: { [weak self] in
            self?.request(req, decoder: decoder, completion: completion)
        }, failed: { error in
            completion?(ResultResult<T, ApiError>.t(error: error))
        }, notNeeded: { [weak self] in
            self?.privateRequest(req, decoder: decoder, completion: completion)
        })
    }
    
    /**
    Runs a request.
    - parameter req:        The request.
    - parameter decoder:    The decoder.
    - parameter completion: The completion closure.
    */
    func request(req: URLRequestAuthenticable, completion: ((ResultResult<Void, ApiError>.t) -> ())?) {
        request(req, decoder: { object in return Void() }, completion: completion)
    }

    /**
     Executes a renew user token request skipping the regular request flow.

     - parameter userToken:     The user token.
     - parameter decoder:       The decoder.
     - parameter completion:    The completion closure.
     */
    func requestRenewUserToken(userToken: String, decoder: AnyObject -> Authentication?,
                               completion: ((ResultResult<Authentication, ApiError>.t) -> ())?) {
        let request = SessionRouter.UpdateUser(userToken: userToken)
        renewingUser.value = true
        userQueue.suspended = true
        privateRequest(request, decoder: decoder) { [weak self] result in
            completion?(result)
            self?.renewingUser.value = false
            self?.userQueue.suspended = false
        }
    }

    /**
    Handles the private request response.
    - parameter req:        The request.
    - parameter decoder:    The decoder.
    - parameter response:   The response.
    - parameter completion: The completion closure.
    */
    func handlePrivateApiResponse<T>(req: URLRequestAuthenticable, decoder: AnyObject -> T?,
                                     response: Response<T, NSError>,
                                     completion: ((ResultResult<T, ApiError>.t) -> ())?) {
        if shouldRenewToken(response) {
            logMessage(.Verbose, type: [CoreLoggingOptions.Networking, CoreLoggingOptions.Token],
                       message: response.logMessage)

            let requestTokenLevel = decodeRequestToken(response)?.level ?? .Nonexistent
            switch requestTokenLevel {
            case .Installation:
                tokenDAO.deleteInstallationToken()
                request(req, decoder: decoder, completion: completion)
            case .User:
                renewUserTokenOrEnqueueRequest(req, decoder: decoder, completion: completion)
            case .Nonexistent:
                // Should never happen
                logMessage(.Error, type: [CoreLoggingOptions.Networking], message: response.logMessage)
            }
        } else if let error = errorFromAlamofireResponse(response) {
            logMessage(.Verbose, type: [CoreLoggingOptions.Networking], message: response.logMessage)

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
}


// MARK: - Private methods
// MARK: > Pre-request

private extension ApiClient {
    /**
     Renews a token if needed. If a request requires an installation it might create it.

     - parameter decoder:    The decoder.
     - parameter succeeded:  Completion closure executed after renewing a token.
     - parameter failed:     Completion closure executed when token renew failed
     or the required auth level is higher than required.
     - parameter notNeeded:  Completion closure executed when token renew is not needed.
     */
    func renewTokenIfNeeded<T>(request: URLRequestAuthenticable, decoder: AnyObject -> T?, succeeded: (() -> ())?,
                            failed: ((ApiError) -> ())?, notNeeded: (() -> ())?) {
        if shouldRenewInstallationTokenForRequest(request) {
            renewInstallationTokenOrEnqueueRequest(succeeded, failed: failed, notNeeded: notNeeded)
        }
        else if tokenDAO.level == .User && request.requiredAuthLevel == .User {
            if shouldRenewUserTokenForRequest(request) {
                renewUserTokenOrEnqueueRequest(request, decoder: decoder) { result in
                    if let _ = result.value {
                        succeeded?()
                    } else if let error = result.error {
                        failed?(error)
                    }
                }
            } else {
                notNeeded?()
            }
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
     Indicates if the installation token should be renewed. If the request required level is installation, then
     it should be renewed on these cases:
     - if we don't have installation token
     - if we have installation token but doesn't have version or its version is lower than 2
     */
    func shouldRenewInstallationTokenForRequest(request: URLRequestAuthenticable) -> Bool {
        guard request.requiredAuthLevel == .Installation else { return false }
        guard let installationToken = tokenDAO.get(level: .Installation) else { return true }
        guard let installationTokenVersion = installationToken.version else { return true }
        return installationTokenVersion < 2
    }

    /**
     Indicates if the user token should be renewed. It should be renewed on these cases:
     - if we have a user token, the requires requires `.User` level and the token isn't migrated to v2
     */
    func shouldRenewUserTokenForRequest(request: URLRequestAuthenticable) -> Bool {
        guard let userToken = tokenDAO.get(level: .User) where request.requiredAuthLevel == .User else { return false }
        return (userToken.version ?? 0) < 2
    }
}


// MARK: > Response handling

private extension ApiClient {
    /**
     Checks the HTTP response headers to check if token should be renewed.
     - parameter response: The HTTP response.
     - returns: If token should be renewed.
     */
    func shouldRenewToken<T>(response: Response<T, NSError>) -> Bool {
        /**
         When we should renew the token when the response is:

         HTTP/1.1 401 Unauthorized
         WWW-Authenticate: Bearer realm="example",
         error="invalid_token",
         error_description="The access token expired"

         @see: https://tools.ietf.org/html/rfc6750
         */
        guard let statusCode = response.response?.statusCode where statusCode == 401 else {
            return false }
        guard let wwwAuthenticate = response.response?.allHeaderFields["WWW-Authenticate"] as? String else {
            return false
        }
        return wwwAuthenticate.containsString("invalid_token")
    }

    /**
     Handles an API error deleting the `Installation` if unauthorized or logging out the current user if scammer.
     - parameter error: The API error.
     */
    private func handlePrivateApiErrorResponse<T>(error: ApiError, response: Response<T, NSError>) {
        let currentLevel = tokenDAO.level
        switch error {
        case .Scammer:
            // If scammer then force logout
            sessionManager?.tearDownSession(kicked: true)
        case .BadRequest, .Unauthorized, .NotFound, .Conflict, .InternalServerError, .UnprocessableEntity, .UserNotVerified, .Other, .Network,
             .Internal, .NotModified, .Forbidden, .TooManyRequests:
            break
        }

        if let networkReport = CoreReportNetworking(apiError: error, currentAuthLevel: currentLevel) {
            report(networkReport, message: response.logMessage)
        }
    }
}


// MARK: > Installation token renewal

private extension ApiClient {
    /**
     Renews a token if not already doing so, otherwise it queues the request up.
     If a request requires an installation it might create/authenticate it.

     - parameter succeeded:  Completion closure executed after Installation token auth/creation.
     - parameter failed:     Completion closure executed when Installation token auth/creation failed
                             or the required auth level is higher than required.
     - parameter notNeeded:  Completion closure executed when token renew is not needed.
     */
    func renewInstallationTokenOrEnqueueRequest(succeeded: (() -> ())?, failed: ((ApiError) -> ())?,
                                                notNeeded: (() -> ())?) {
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
                dispatch_async(dispatch_get_main_queue()) {
                    guard let strongSelf = self else { return }

                    if strongSelf.tokenDAO.level > .Nonexistent {
                        succeeded?()
                    } else {
                        failed?(.Unauthorized)
                    }
                }
            }
        }
    }
}


// MARK: > User token renewal

private extension ApiClient {

    /**
     Renews the user token to later run the given request or queues the request to be executed when user token is
     renewed.

     - parameter request:    The request originated the renewal.
     - parameter decoder:    The decoder.
     - parameter completion: The completion closure.
     */
    func renewUserTokenOrEnqueueRequest<T>(req: URLRequestAuthenticable, decoder: AnyObject -> T?,
                                        completion: ((ResultResult<T, ApiError>.t) -> ())?) {
        if !renewingUser.value {
            renewingUser.value = true
            userQueue.suspended = true

            sessionManager?.renewUserToken { [weak self] result in

                self?.renewingUser.value = false
                self?.userQueue.suspended = false

                if let error = result.error {
                    completion?(ResultResult<T, ApiError>.t(error: error))
                } else {
                    self?.request(req, decoder: decoder, completion: completion)
                }
            }
        } else {
            let tokenBeforeRenew = tokenDAO.token.value
            userQueue.addOperationWithBlock { [weak self] in
                dispatch_async(dispatch_get_main_queue()) {
                    guard self?.tokenDAO.token.value != tokenBeforeRenew else {
                        completion?(ResultResult<T, ApiError>.t(error: .Unauthorized))
                        return
                    }
                    self?.request(req, decoder: decoder, completion: completion)
                }
            }
        }
    }
}


// MARK: - Private methods (legacy)
// TODO: must be removed as soon as all APIs use bouncer v2

private extension ApiClient {

    /**
     Checks the HTTP response headers to check if token should be renewed.
     - parameter response: The HTTP response.
     - returns: If token should be renewed.
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
    func decodeToken<T>(response: Response<T, NSError>) -> Token? {
        guard let authenticationInfo = response.response?.allHeaderFields["authentication-info"] as? String else {
            return nil
        }
        return decodeAuthInfo(authenticationInfo)
    }

    /**
     Decodes the given response's request and returns a token.
     - parameter response: The request response.
     - returns: The token with value as `"Bearer <token>"`.
     */
    func decodeRequestToken<T>(response: Response<T, NSError>) -> Token? {
        guard let authenticationInfo = response.request?.allHTTPHeaderFields?["Authorization"] else {
            return nil
        }
        return decodeAuthInfo(authenticationInfo)
    }

    /**
     Decodes the given auth info and returns a token.
     - parameter authInfo: The auth info.
     - returns: The token with value as `"Bearer <token>"`.
     */
    func decodeAuthInfo(authInfo: String) -> Token? {
        guard let token = authInfo.componentsSeparatedByString(" ").last,
            authLevel = token.tokenAuthLevel else {
                logMessage(.Error, type: [CoreLoggingOptions.Networking, CoreLoggingOptions.Token],
                           message: "Invalid JWT; authentication-info: \(authInfo)")
                report(CoreReportNetworking.InvalidJWT, message: "authentication-info: \(authInfo)")
                return nil
        }
        return Token(value: authInfo, level: authLevel)
    }
}


// MARK: - Token helper

private extension Token {
    var version: Int? {
        guard let token = value?.componentsSeparatedByString(" ").last,
            payload = try? JWT.decode(token, algorithm: .HS256(""), verify: false) else { return nil }
        let version = payload["btv"] as? Int
        return version
    }
}


// MARK: - Custom api error

extension Response {
    var apiErrorCode: Int? {
        guard let data = self.data where data.length > 0 else { return nil }
        guard let value = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else { return nil }
        let code: LGApiErrorCode? = decode(value)
        guard let codeString = code?.code else { return nil }
        return Int(codeString)
    }
}
