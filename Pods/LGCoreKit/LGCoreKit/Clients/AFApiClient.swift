//
//  ApiClient.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 02/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

public enum ConflictCause {

    case UserExists
    case EmailRejected
    case RequestAlreadyProcessed

    case NotSpecified
    case Other(code: Int)

    static func causeWithCode(code: Int?) -> ConflictCause {
        guard let code = code else { return .NotSpecified }
        switch code {
        case 1005:
            return .UserExists
        case 1009:
            return .EmailRejected
        case 1102:
            return .RequestAlreadyProcessed
        default:
            return .Other(code: code)
        }
    }
}

public enum ApiError: ErrorType {
    // errorCode references NSURLError codes (i.e. NSURLErrorUnknown)
    case Network(errorCode: Int)
    case Internal(description: String)

    case Unauthorized
    case NotFound
    case Forbidden
    case Conflict(cause: ConflictCause)
    case Scammer
    case UnprocessableEntity
    case UserNotVerified
    case TooManyRequests
    case InternalServerError(httpCode: Int)
    case NotModified
    case Other(httpCode: Int)

    static func errorForCode(code: Int, apiCode: Int?) -> ApiError {
        switch code {
        case 304:
            return .NotModified
        case 401:   // Wrong credentials
            return .Unauthorized
        case 403:
            return .Forbidden
        case 404:
            return .NotFound
        case 409:
            return .Conflict(cause: ConflictCause.causeWithCode(apiCode))
        case 418:   // I'm a teapot! 🍵
            return .Scammer
        case 422:
            return .UnprocessableEntity
        case 424: // Failed dependency 🤔
            return .UserNotVerified
        case 429:
            return .TooManyRequests
        case 500..<600:
            return .InternalServerError(httpCode: code)
        default:
            return .Other(httpCode: code)
        }
    }

    var httpStatusCode: Int? {
        switch self {
        case .Network, .Internal:
            return nil
        case let .Other(httpCode):
            return httpCode
        case .NotModified:
            return 304
        case .Unauthorized:
            return 401
        case .NotFound:
            return 404
        case .Forbidden:
            return 403
        case .Conflict:
            return 409
        case .Scammer:
            return 418
        case .UnprocessableEntity:
            return 422
        case .UserNotVerified:
            return 424
        case .TooManyRequests:
            return 429
        case let .InternalServerError(httpCode):
            return httpCode
        }
    }
}

protocol URLRequestAuthenticable: URLRequestConvertible, ReportableRequest {
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

    var renewingInstallation: Bool
    let installationQueue: NSOperationQueue

    // MARK: - Lifecycle
    
    init(alamofireManager: Manager, tokenDAO: TokenDAO) {
        self.alamofireManager = alamofireManager
        self.tokenDAO = tokenDAO
        self.renewingInstallation = false
        self.installationQueue = NSOperationQueue()

        installationQueue.maxConcurrentOperationCount = 1
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
                case .Failure:
                    let description = "Multipart form data encoding failed"
                    completion?(ResultResult<T, ApiError>.t(error: .Internal(description: description)))
                }
            }
    }
}
