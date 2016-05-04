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
    case Forbidden
    case AlreadyExists
    case Scammer
    case UnprocessableEntity
    case InternalServerError
    case NotModified


    static func errorForCode(code: Int) -> ApiError {
        switch code {
        case 304:
            return .NotModified
        case 400:   // Bad request is our fault
            return .Internal
        case 401:   // Wrong credentials
            return .Unauthorized
        case 403:
            return .Forbidden
        case 404:
            return .NotFound
        case 409:   // Conflict
            return .AlreadyExists
        case 418:   // I'm a teapot! 🍵
            return .Scammer
        case 422:
            return .UnprocessableEntity
        case 500..<600:
            return .InternalServerError
        default:
            return .Internal
        }
    }
}

protocol URLRequestAuthenticable: URLRequestConvertible {
    var requiredAuthLevel: AuthLevel { get }
    var acceptedStatus: Array<Int> { get }
}

extension URLRequestAuthenticable {
    var acceptedStatus: Array<Int> {
        return [Int](200..<400)
    }
}

class AFApiClient: ApiClient {

    let alamofireManager: Manager
    weak var sessionManager: SessionManager?
    weak var installationRepository: InstallationRepository?
    let tokenDAO: TokenDAO
    
    
    // MARK: - Lifecycle
    
    init(alamofireManager: Manager, tokenDAO: TokenDAO) {
        self.alamofireManager = alamofireManager
        self.tokenDAO = tokenDAO
    }

    
    // MARK: - ApiClient
    
    func privateRequest<T>(req: URLRequestAuthenticable, decoder: AnyObject -> T?,
        completion: ((ResultResult<T, ApiError>.t) -> ())?) {

            logMessage(.Verbose, type: CoreLoggingOptions.Networking, message: req.logMessage)

            alamofireManager.request(req).validate(statusCode: req.acceptedStatus).responseObject(decoder) {
                [weak self] (response: Response<T, NSError>) in
                self?.handlePrivateApiErrorResponse(req, response: response, completion: completion)
            }
    }
    
    func upload<T>(request: URLRequestAuthenticable, decoder: AnyObject -> T?,
        multipart: MultipartFormData -> Void, completion: ((ResultResult<T, ApiError>.t) -> ())?,
        progress: ((written: Int64, totalWritten: Int64, totalExpectedToWrite: Int64) -> Void)?) {
            
            guard request.requiredAuthLevel <= tokenDAO.level else {
                completion?(ResultResult<T, ApiError>.t(error: .Unauthorized))
                report(CoreReportSession.InsufficientTokenLevel, message: "when uploading")
                return
            }

            logMessage(.Verbose, type: CoreLoggingOptions.Networking, message: request.logMessage)
            
            alamofireManager.upload(request, multipartFormData: multipart) { result in
                
                switch result {
                case let .Success(upload, _, _):
                    upload.validate(statusCode: 200..<400)
                        .responseObject(decoder) { [weak self] (response: Response<T, NSError>) in
                            if let actualError = self?.errorFromAlamofireResponse(response) {
                                logMessage(.Info, type: CoreLoggingOptions.Networking, message: response.logMessage)
                                completion?(ResultResult<T, ApiError>.t(error: actualError))
                            } else if let uploadFileResponse = response.result.value {
                                logMessage(.Verbose, type: CoreLoggingOptions.Networking, message: response.logMessage)
                                completion?(ResultResult<T, ApiError>.t(value: uploadFileResponse))
                            }
                        }.progress(progress)
                case .Failure(_):
                    completion?(ResultResult<T, ApiError>.t(error: .Internal))
                }
            }
    }
}
