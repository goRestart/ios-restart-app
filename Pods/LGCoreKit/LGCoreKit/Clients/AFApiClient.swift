//
//  ApiClient.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 02/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result
import RxSwift

enum TimeOutDefaults {
    static let noHost = "could not retrieve host"
    static let noEndPoint = "could not retrieve endpoint"
}

public enum ConflictCause {

    case userExists
    case emailRejected
    case requestAlreadyProcessed
    case searchAlertAlreadyExists
    case searchAlertLimitReached

    case notSpecified
    case other(code: Int)

    static func causeWithCode(_ code: Int?) -> ConflictCause {
        guard let code = code else { return .notSpecified }
        switch code {
        case 1005:
            return .userExists
        case 1009:
            return .emailRejected
        case 1102:
            return .requestAlreadyProcessed
        default:
            return .other(code: code)
        }
    }
    
    static func causeWithSearchAlertCode(_ code: SearchAlertsErrorCode) -> ConflictCause {
        switch code {
        case .alreadyExists:
            return .searchAlertAlreadyExists
        case .limitReached:
            return .searchAlertLimitReached
        }
    }
}

public enum BadRequestCause {

    case nonAcceptableParams

    case notSpecified
    case other(code: Int)

    static func causeWithCode(_ code: Int?) -> BadRequestCause {
        guard let code = code else { return .notSpecified }
        switch code {
        case 2007:
            return .nonAcceptableParams
        default:
            return .other(code: code)
        }
    }
}

public enum ForbiddenCause: Equatable {
    
    case emailTaken
    case userBlocked
    case notSpecified
    case differentCountry
    case other(code: Int)
    
    static func causeWithCode(_ code: Int?) -> ForbiddenCause {
        guard let code = code else { return .notSpecified }
        switch code {
        case 1010:
            return .emailTaken
        case 11001, 12001:
            return .differentCountry
        default:
            return .other(code: code)
        }
    }
}

public func ==(lhs: ForbiddenCause, rhs: ForbiddenCause) -> Bool {
    switch (lhs, rhs) {
    case (.emailTaken, .emailTaken): return true
    case (.userBlocked, .userBlocked): return true
    case (.notSpecified, .notSpecified): return true
    case (.differentCountry, .differentCountry): return true
    case (.other(let a), .other(let b)) where a == b: return true
    default: return false
    }
}

public enum ApiError: Error {
    // errorCode references URLError codes (i.e. URLErrorUnknown)
    case network(errorCode: Int, onBackground: Bool, requestHost: String?)
    case internalError(description: String)

    case badRequest(cause: BadRequestCause)
    case unauthorized(description: String?)
    case notFound
    case forbidden(cause: ForbiddenCause)
    case conflict(cause: ConflictCause)
    case scammer
    case unprocessableEntity
    case userNotVerified
    case tooManyRequests
    case internalServerError(httpCode: Int)
    case notModified
    case other(httpCode: Int)

    static func errorForCode(_ code: Int, apiCode: Int?, description: String?) -> ApiError {
        switch code {
        case 304:
            return .notModified
        case 400:
            return .badRequest(cause: BadRequestCause.causeWithCode(apiCode))
        case 401:   // Wrong credentials
            return .unauthorized(description: description ?? "Token expired on server")
        case 403:
            return .forbidden(cause: ForbiddenCause.causeWithCode(apiCode))
        case 404:
            return .notFound
        case 409:
            return .conflict(cause: ConflictCause.causeWithCode(apiCode))
        case 418:   // I'm a teapot! 🍵
            return .scammer
        case 422:
            return .unprocessableEntity
        case 424: // Failed dependency 🤔
            return .userNotVerified
        case 429:
            return .tooManyRequests
        case 500..<600:
            return .internalServerError(httpCode: code)
        default:
            return .other(httpCode: code)
        }
    }

    static func errorForSearchAlertCode(_ apiCode: SearchAlertsErrorCode) -> ApiError {
        return .conflict(cause: ConflictCause.causeWithSearchAlertCode(apiCode))
    }
    
    var httpStatusCode: Int? {
        switch self {
        case .network, .internalError:
            return nil
        case let .other(httpCode):
            return httpCode
        case .notModified:
            return 304
        case .badRequest:
            return 400
        case .unauthorized:
            return 401
        case .notFound:
            return 404
        case .forbidden:
            return 403
        case .conflict:
            return 409
        case .scammer:
            return 418
        case .unprocessableEntity:
            return 422
        case .userNotVerified:
            return 424
        case .tooManyRequests:
            return 429
        case let .internalServerError(httpCode):
            return httpCode
        }
    }
}

enum ErrorDecoderType {
    case apiUsersError
    case apiProductsError
    case searchAlertsError
}

protocol URLRequestAuthenticable: URLRequestConvertible, ReportableRequest {
    var requiredAuthLevel: AuthLevel { get }
    var acceptedStatus: Array<Int> { get }
    var errorDecoderType: ErrorDecoderType? { get }
}

extension URLRequestAuthenticable {
    var acceptedStatus: Array<Int> {
        return [Int](200..<400)
    }
    
    var errorDecoderType: ErrorDecoderType? {
        return nil
    }
}

class AFApiClient: ApiClient {

    let alamofireManager: Alamofire.SessionManager
    weak var sessionManager: InternalSessionManager?
    weak var installationRepository: InstallationRepository?

    let tokenDAO: TokenDAO

    var renewingInstallation: Bool
    let installationQueue: OperationQueue

    let renewingUser = Variable<Bool>(false)
    var userQueue: OperationQueue

    var tracker: CoreTracker?

    // MARK: - Lifecycle
    
    init(alamofireManager: Alamofire.SessionManager, tokenDAO: TokenDAO, tracker: CoreTracker?) {
        self.alamofireManager = alamofireManager
        self.tokenDAO = tokenDAO
        self.tracker = tracker
        self.renewingInstallation = false
        self.installationQueue = OperationQueue()
        self.renewingUser.value = false
        self.userQueue = OperationQueue()

        installationQueue.maxConcurrentOperationCount = 1
        userQueue.maxConcurrentOperationCount = 1
    }

    
    // MARK: - ApiClient
    
    func privateRequest<T>(_ req: URLRequestAuthenticable, decoder: @escaping (Any) -> T?,
        completion: ((ResultResult<T, ApiError>.t) -> ())?) {

        logMessage(.verbose, type: CoreLoggingOptions.networking, message: req.debugMessage)

        alamofireManager.request(req).validate(statusCode: req.acceptedStatus).responseObject(decoder) {
            [weak self] (response: DataResponse<T>) in
            self?.handlePrivateApiResponse(req, decoder: decoder, response: response, completion: completion)
        }
    }

    func upload<T>(_ request: URLRequestAuthenticable, decoder: @escaping (Any) -> T?,
        multipart: @escaping (MultipartFormData) -> Void, completion: ((ResultResult<T, ApiError>.t) -> ())?,
        progress: ((Progress) -> Void)?) {
            
            guard request.requiredAuthLevel <= tokenDAO.level else {
                let errorDescription = "required auth level: \(request.requiredAuthLevel); current level: \(tokenDAO.level) when uploading"
                completion?(ResultResult<T, ApiError>.t(error: .unauthorized(description: errorDescription)))
                report(CoreReportSession.insufficientTokenLevel, message: "when uploading")
                return
            }

            logMessage(.verbose, type: CoreLoggingOptions.networking, message: request.debugMessage)

            alamofireManager.upload(multipartFormData: multipart, with: request) { result in
                switch result {
                case let .success(upload, _, _):
                    let dataRequest = upload.validate(statusCode: 200..<400)
                        .responseObject(decoder) { [weak self] (response: DataResponse<T>) in
                            if let actualError = self?.errorFromAlamofireResponse(errorDecoderType: request.errorDecoderType, response: response) {
                                logMessage(.info, type: CoreLoggingOptions.networking, message: response.debugMessage)
                                completion?(ResultResult<T, ApiError>.t(error: actualError))
                            } else if let uploadFileResponse = response.result.value {
                                logMessage(.verbose, type: CoreLoggingOptions.networking, message: response.debugMessage)
                                completion?(ResultResult<T, ApiError>.t(value: uploadFileResponse))
                            }
                        }
                    if let progress = progress {
                        dataRequest.downloadProgress(closure: progress)
                    }
                case .failure:
                    let description = "Multipart form data encoding failed"
                    completion?(ResultResult<T, ApiError>.t(error: .internalError(description: description)))
                }
            }
    }
}
