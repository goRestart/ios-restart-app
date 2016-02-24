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
            return .Internal
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
            
            alamofireManager.request(req).validate(statusCode: 200..<400).responseObject(decoder) {
                [weak self] (response: Response<T, NSError>) in
                self?.handlePrivateApiErrorResponse(req, response: response, completion: completion)
            }
    }
    
    func upload<T>(request: URLRequestAuthenticable, decoder: AnyObject -> T?,
        multipart: MultipartFormData -> Void, completion: ((ResultResult<T, ApiError>.t) -> ())?,
        progress: ((written: Int64, totalWritten: Int64, totalExpectedToWrite: Int64) -> Void)?) {
            
            guard request.requiredAuthLevel <= tokenDAO.level else {
                completion?(ResultResult<T, ApiError>.t(error: .Unauthorized))
                return
            }
            
            alamofireManager.upload(request, multipartFormData: multipart) { result in
                
                switch result {
                case let .Success(upload, _, _):
                    upload.validate(statusCode: 200..<400)
                        .responseObject(decoder) { [weak self] (response: Response<T, NSError>) in
                            if let actualError = self?.errorFromAlamofireResponse(response) {
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
}