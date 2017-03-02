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
    weak var sessionManager: InternalSessionManager? { get }
    weak var installationRepository: InstallationRepository? { get }

    var tokenDAO: TokenDAO { get }

    var renewingInstallation: Bool { get set }
    var installationQueue: OperationQueue { get }

    var renewingUser: Variable<Bool> { get }
    var userQueue: OperationQueue { get }

    /**
    Executes the given request with a decoder.
    - parameter request: The request.
    - parameter decoder: The decoder.
    - parameter completion: The completion closure.
    */
    func privateRequest<T>(_ request: URLRequestAuthenticable, decoder: @escaping (Any) -> T?,
        completion: ((ResultResult<T, ApiError>.t) -> ())?)

    /**
    Uploads a file.
    - parameter request: The request.
    - parameter decoder: The decoder.
    - parameter multipart: The multipart encoder.
    - parameter completion: The completion closure.
    - parameter progress: The closure that notifies about the upload progress.
    */
    func upload<T>(_ request: URLRequestAuthenticable, decoder: @escaping (Any) -> T?,
            multipart: @escaping (MultipartFormData) -> Void, completion: ((ResultResult<T, ApiError>.t) -> ())?,
            progress: ((Progress) -> Void)?)
}


// MARK: - Internal methods

extension ApiClient {
    /**
    Runs a request.
    - parameter req:        The request.
    - parameter decoder:    The decoder.
    - parameter completion: The completion closure.
    */
    func request<T>(_ req: URLRequestAuthenticable, decoder: @escaping (Any) -> T?,
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
    func request(_ req: URLRequestAuthenticable, completion: ((ResultResult<Void, ApiError>.t) -> ())?) {
        request(req, decoder: { object in return Void() }, completion: completion)
    }

    /**
     Executes a renew user token request skipping the regular request flow.

     - parameter userToken:     The user token.
     - parameter decoder:       The decoder.
     - parameter completion:    The completion closure.
     */
    func requestRenewUserToken(_ userToken: String, decoder: @escaping (Any) -> Authentication?,
                               completion: ((ResultResult<Authentication, ApiError>.t) -> ())?) {
        let request = SessionRouter.updateUser(userToken: userToken)
        renewingUser.value = true
        userQueue.isSuspended = true
        privateRequest(request, decoder: decoder) { [weak self] result in
            completion?(result)
            self?.renewingUser.value = false
            self?.userQueue.isSuspended = false
        }
    }

    /**
    Handles the private request response.
    - parameter req:        The request.
    - parameter decoder:    The decoder.
    - parameter response:   The response.
    - parameter completion: The completion closure.
    */
    func handlePrivateApiResponse<T>(_ req: URLRequestAuthenticable, decoder: @escaping (Any) -> T?,
                                     response: DataResponse<T>,
                                     completion: ((ResultResult<T, ApiError>.t) -> ())?) {
        if shouldRenewToken(response) {
            logMessage(.verbose, type: [CoreLoggingOptions.networking, CoreLoggingOptions.token],
                       message: response.logMessage)

            let requestTokenLevel = decodeRequestToken(response)?.level ?? .nonexistent
            switch requestTokenLevel {
            case .installation:
                tokenDAO.deleteInstallationToken()
                request(req, decoder: decoder, completion: completion)
            case .user:
                renewUserTokenOrEnqueueRequest(req, decoder: decoder, completion: completion)
            case .nonexistent:
                logMessage(.error, type: [CoreLoggingOptions.networking], message: response.logMessage)
                completion?(ResultResult<T, ApiError>.t(error: .unauthorized))
            }
        } else if let error = errorFromAlamofireResponse(response) {
            logMessage(.verbose, type: [CoreLoggingOptions.networking], message: response.logMessage)

            handlePrivateApiErrorResponse(error, response: response)
            completion?(ResultResult<T, ApiError>.t(error: error))
        } else if let value = response.result.value {
            logMessage(.info, type: CoreLoggingOptions.networking, message: response.logMessage)
            updateToken(response)
            completion?(ResultResult<T, ApiError>.t(value: value))
        }
    }

    /**
     Returns an `ApiError` from the given response.
     - parameter response: The request response.
     - returns An `ApiError`.
     */
    func errorFromAlamofireResponse<T>(_ response: DataResponse<T>) -> ApiError? {
        guard let error = response.result.error else { return nil }
        if let afError = error as? AFError, let urlError = afError.underlyingError as? URLError {
            let onBackground = urlError.errorCode == -997
            return .network(errorCode: urlError.errorCode, onBackground: onBackground)
        } else if let urlError = error as? URLError {
            let onBackground = urlError.errorCode == -997
            return .network(errorCode: urlError.errorCode, onBackground: onBackground)
        } else if let statusCode = response.response?.statusCode {
            return ApiError.errorForCode(statusCode, apiCode: response.apiErrorCode)
        } else {
            return ApiError.internalError(description: error.localizedDescription)
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
    func renewTokenIfNeeded<T>(_ request: URLRequestAuthenticable, decoder: @escaping (Any) -> T?, succeeded: (() -> ())?,
                            failed: ((ApiError) -> ())?, notNeeded: (() -> ())?) {
        if shouldRenewInstallationTokenForRequest(request) {
            renewInstallationTokenOrEnqueueRequest(succeeded, failed: failed, notNeeded: notNeeded)
        }
        else if tokenDAO.level == .user && request.requiredAuthLevel == .user {
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
            failed?(.unauthorized)
            report(CoreReportSession.insufficientTokenLevel,
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
    func shouldRenewInstallationTokenForRequest(_ request: URLRequestAuthenticable) -> Bool {
        guard request.requiredAuthLevel == .installation else { return false }
        guard let installationToken = tokenDAO.get(level: .installation) else { return true }
        guard let installationTokenVersion = installationToken.version else { return true }
        return installationTokenVersion < 2
    }

    /**
     Indicates if the user token should be renewed. It should be renewed on these cases:
     - if we have a user token, the requires requires `.User` level and the token isn't migrated to v2
     */
    func shouldRenewUserTokenForRequest(_ request: URLRequestAuthenticable) -> Bool {
        guard let userToken = tokenDAO.get(level: .user), request.requiredAuthLevel == .user else { return false }
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
    func shouldRenewToken<T>(_ response: DataResponse<T>) -> Bool {
        /**
         When we should renew the token when the response is:

         HTTP/1.1 401 Unauthorized
         WWW-Authenticate: Bearer realm="example",
         error="invalid_token",
         error_description="The access token expired"

         @see: https://tools.ietf.org/html/rfc6750
         */
        guard let statusCode = response.response?.statusCode, statusCode == 401 else {
            return false }

        // 👀 Stubs or alamofire somehow change WWW-Authenticate by Www-Authenticate magically...
        let authenticateObject: Any? = (response.response?.allHeaderFields["WWW-Authenticate"] ?? response.response?.allHeaderFields["Www-Authenticate"])
        guard let wwwAuthenticate = authenticateObject as? String else {
            return false
        }
        return wwwAuthenticate.contains("invalid_token")
    }

    /**
     Handles an API error deleting the `Installation` if unauthorized or logging out the current user if scammer.
     - parameter error: The API error.
     */
    func handlePrivateApiErrorResponse<T>(_ error: ApiError, response: DataResponse<T>) {
        let currentLevel = tokenDAO.level
        switch error {
        case .scammer:
            // If scammer then force logout
            sessionManager?.tearDownSession(kicked: true)
        case .badRequest, .unauthorized, .notFound, .conflict, .internalServerError, .unprocessableEntity, .userNotVerified, .other, .network,
             .internalError, .notModified, .forbidden, .tooManyRequests:
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
    func renewInstallationTokenOrEnqueueRequest(_ succeeded: (() -> ())?, failed: ((ApiError) -> ())?,
                                                notNeeded: (() -> ())?) {
        if !renewingInstallation {
            renewingInstallation = true
            installationQueue.isSuspended = true

            sessionManager?.authenticateInstallation { [weak self] result in
                guard let strongSelf = self else { return }

                if let _ = result.value {
                    succeeded?()
                } else if let error = result.error {
                    failed?(error)
                }
                strongSelf.renewingInstallation = false
                strongSelf.installationQueue.isSuspended = false
            }
        } else {
            installationQueue.addOperation { [weak self] in
                DispatchQueue.main.async {
                    guard let strongSelf = self else { return }

                    if strongSelf.tokenDAO.level > .nonexistent {
                        succeeded?()
                    } else {
                        failed?(.unauthorized)
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
    func renewUserTokenOrEnqueueRequest<T>(_ req: URLRequestAuthenticable, decoder: @escaping (Any) -> T?,
                                        completion: ((ResultResult<T, ApiError>.t) -> ())?) {
        if !renewingUser.value {
            sessionManager?.renewUserToken { [weak self] result in
                if let error = result.error {
                    completion?(ResultResult<T, ApiError>.t(error: error))
                } else {
                    self?.request(req, decoder: decoder, completion: completion)
                }
            }
        } else {
            let tokenBeforeRenew = tokenDAO.token.value
            userQueue.addOperation { [weak self] in
                DispatchQueue.main.async {
                    guard self?.tokenDAO.token.value != tokenBeforeRenew else {
                        completion?(ResultResult<T, ApiError>.t(error: .unauthorized))
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
    func updateToken<T>(_ response: DataResponse<T>) {
        guard let token = decodeToken(response) else { return }
        if let sessionManager = sessionManager, token.level == .user && !sessionManager.loggedIn {
            logMessage(.error, type: [CoreLoggingOptions.networking, CoreLoggingOptions.token],
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
    func decodeToken<T>(_ response: DataResponse<T>) -> Token? {
        // 👀 Stubs or alamofire somehow change authentication-info by Authentication-Info magically...
        let authenticationData: Any? = (response.response?.allHeaderFields["authentication-info"] ??
            response.response?.allHeaderFields["Authentication-Info"])
        guard let authenticationInfo = authenticationData as? String else {
            return nil
        }
        return decodeAuthInfo(authenticationInfo)
    }

    /**
     Decodes the given response's request and returns a token.
     - parameter response: The request response.
     - returns: The token with value as `"Bearer <token>"`.
     */
    func decodeRequestToken<T>(_ response: DataResponse<T>) -> Token? {
        guard let authorization = response.request?.allHTTPHeaderFields?["Authorization"] else {
            return nil
        }
        return decodeAuthInfo(authorization)
    }

    /**
     Decodes the given auth info and returns a token.
     - parameter authInfo: The auth info.
     - returns: The token with value as `"Bearer <token>"`.
     */
    func decodeAuthInfo(_ authInfo: String) -> Token? {
        guard let token = authInfo.lastComponentSeparatedByCharacter(" ") else {
            logMessage(.error, type: [CoreLoggingOptions.networking, CoreLoggingOptions.token],
                       message: "Invalid JWT with wrong format; authentication-info: \(authInfo)")
            report(CoreReportNetworking.invalidJWT(reason: .wrongFormat),
                   message: "authentication-info: \(authInfo)")
            return nil
        }
        guard let authLevel = token.tokenAuthLevel else {
            if !token.isPasswordRecoveryToken {
                logMessage(.error, type: [CoreLoggingOptions.networking, CoreLoggingOptions.token],
                           message: "Invalid JWT with unknown auth level; authentication-info: \(authInfo)")
                report(CoreReportNetworking.invalidJWT(reason: .unknownAuthLevel),
                       message: "authentication-info: \(authInfo)")
            }
            return nil
        }


        return Token(value: authInfo, level: authLevel)
    }
}


// MARK: - Token helper

private extension Token {
    var version: Int? {
        guard let token = actualValue,
            let payload = try? JWT.decode(token, algorithm: .hs256(Data()), verify: false) else { return nil }
        let version = payload["btv"] as? Int
        return version
    }
}


// MARK: - Custom api error

extension DataResponse {
    var apiErrorCode: Int? {
        guard let data = self.data, data.count > 0 else { return nil }
        guard let value = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        let code: LGApiErrorCode? = decode(value)
        guard let codeString = code?.code else { return nil }
        return Int(codeString)
    }
}
