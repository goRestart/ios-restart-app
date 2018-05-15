//
//  LGPreSignedUploadUrlDataSource.swift
//  LGCoreKit
//
//  Created by Álvaro Murillo del Puerto on 11/4/18.
//

import Foundation
import Result

typealias PreSignedUploadUrlDataSourceResult = Result<PreSignedUploadUrl, ApiError>
typealias PreSignedUploadUrlDataSourceCompletion = (PreSignedUploadUrlDataSourceResult) -> Void

typealias PreSignedUploadUrlUploadDataSourceResult = Result<Void, ApiError>
typealias PreSignedUploadUrlUploadDataSourceCompletion = (PreSignedUploadUrlUploadDataSourceResult) -> Void

protocol PreSignedUploadUrlDataSource {

    func create(fileExtension: String, completion: PreSignedUploadUrlDataSourceCompletion?)

    func upload(url: URL,
                inputs: [String: String],
                file: URL,
                progress: ((Float) -> ())?,
                completion: PreSignedUploadUrlUploadDataSourceCompletion?)
}

final class LGPreSignedUploadUrlDataSource: PreSignedUploadUrlDataSource {

    let apiClient: ApiClient

    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func create(fileExtension: String, completion: PreSignedUploadUrlDataSourceCompletion?) {

        let params: [String: Any] = ["extension": fileExtension]
        let request = PreSignedUploadUrlRouter.create(params: params)

        apiClient.request(request, decoder: LGPreSignedUploadUrlDataSource.decoder) { result in
            switch result {
            case let .failure(error):
                completion?(PreSignedUploadUrlDataSourceResult(error: error))
            case let .success(form):
                completion?(PreSignedUploadUrlDataSourceResult(value: form))
            }
        }
    }

    func upload(url: URL,
                inputs: [String: String],
                file: URL,
                progress: ((Float) -> ())?,
                completion: PreSignedUploadUrlUploadDataSourceCompletion?) {

        let request = PreSignedUploadUrlRouter.upload(url: url)

        apiClient.upload(request, decoder: {$0}, multipart: { multipart in
            for input in inputs {
                guard let data = input.value.data(using: .utf8, allowLossyConversion: true) else {
                    let error = ApiError.internalError(description: "error converting input string to data: \(input)")
                    completion?(PreSignedUploadUrlUploadDataSourceResult(error: error))
                    return
                }
                multipart.append(data, withName: input.key)
            }
            multipart.append(file, withName: "file")
        }, completion: { result in
            switch result {
            case let .failure(error):
                completion?(PreSignedUploadUrlUploadDataSourceResult(error: error))
            case .success:
                completion?(PreSignedUploadUrlUploadDataSourceResult(value: ()))
            }
        }) { progressData in
            var p: Float = 0
            if progressData.totalUnitCount > 0 {
                p = Float(progressData.completedUnitCount)/Float(progressData.totalUnitCount)
            }
            progress?(p)
        }
    }

    // MARK: - Decoder

    static func decoder(object: Any) -> LGPreSignedUploadUrl? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }

        do {
            return try LGPreSignedUploadUrl.decode(jsonData: data)
        } catch {
            logAndReportParseError(object: object, entity: .preSignedUploadUrl,
                                   comment: "\(error.localizedDescription)")
        }
        return nil
    }
}
