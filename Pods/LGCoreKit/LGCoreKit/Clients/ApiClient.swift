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

protocol ApiClient: class, Loggable {
    weak var sessionManager: SessionManager? { get }
    weak var installationRepository: InstallationRepository? { get }
    var tokenDAO: TokenDAO { get }
    
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
            
            createInstallationIfNeeded(req,
                createSucceeded: { [weak self] in
                    self?.request(req, decoder: decoder, completion: completion)
                },
                failed: { error in
                    completion?(ResultResult<T, ApiError>.t(error: error))
                },
                createNotNeeded: { [weak self] in
                    self?.privateRequest(req, decoder: decoder, completion: completion)
                }
            )
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
                handlePrivateApiErrorResponse(error, response: response)
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
    func errorFromAlamofireResponse<T>(response: Response<T, NSError>) -> ApiError? {
        guard let error = response.result.error else { return nil }
        if error.domain == NSURLErrorDomain {
            return .Network
        } else if let statusCode = response.response?.statusCode {
            return ApiError.errorForCode(statusCode)
        } else {
            return .Internal
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
    private func createInstallationIfNeeded(request: URLRequestAuthenticable, createSucceeded: (() -> ())?,
        failed: ((ApiError) -> ())?, createNotNeeded: (() -> ())?) {
            
            if tokenDAO.level == .None && request.requiredAuthLevel > .None {
                installationRepository?.create { result in
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
    Handles an API error deleting the `Installation` if unauthorized or logging out the current user if scammer.
    - parameter error: The API error.
    */
    private func handlePrivateApiErrorResponse<T>(error: ApiError, response: Response<T, NSError>) {
            switch error {
            case .Unauthorized:
                let currentLevel = tokenDAO.level
                switch currentLevel {
                case .None:
                    break
                case .User:
                    sessionManager?.tearDownSession(kicked: true)
                    logResponse(response)
                case .Installation:
                    // Erase installation and all tokens
                    installationRepository?.delete()
                    tokenDAO.reset()
                }
            case .Scammer:
                // If scammer then force logout
                sessionManager?.tearDownSession(kicked: true)
                logResponse(response)
            case .Network, .Internal, .NotFound, .AlreadyExists, .InternalServerError:
                break
            }
    }
    
    /**
    Updates the token with the given request response.
    - parameter response: The request response.
    */
    private func updateToken<T>(response: Response<T, NSError>) {
        guard let token = decodeToken(response) else { return }
        tokenDAO.save(token)
    }
    
    /**
    Decodes the given response and returns a token.
    - parameter response: The request response.
    - returns: The token with value as `"Bearer <token>"`.
    */
    private func decodeToken<T>(response: Response<T, NSError>) -> Token? {
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

    private func logResponse<T>(response: Response<T, NSError>) {
        let urlRequest = response.request?.URLString ?? "empty"
        let requestHeaders = response.request?.allHTTPHeaderFields?.description ?? "empty"
        var requestBody: String = "empty"
        if let httpBody = response.request?.HTTPBody {
            requestBody = String(data: httpBody, encoding: NSUTF8StringEncoding) ?? "empty"
        }
        let responseHeaders = response.response?.allHeaderFields.description ?? "empty"
        let statusCode = response.response?.statusCode ?? -1

        let message = "Request: \(urlRequest) " +
                    "\n->requestHeaders: \(requestHeaders) " +
                    "\n->requestBody: \(requestBody)" +
                    "\n<-statusCode: \(statusCode)"
                    "\n<-responseHeaders: \(responseHeaders)"
        logError(message)
    }
}