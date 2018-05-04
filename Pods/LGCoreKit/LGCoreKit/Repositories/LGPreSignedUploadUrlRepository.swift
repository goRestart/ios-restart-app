//
//  LGPreSignedUploadUrlRepository.swift
//  LGCoreKit
//
//  Created by Álvaro Murillo del Puerto on 13/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Result

public typealias PreSignedUploadUrlResult = Result<PreSignedUploadUrl, RepositoryError>
public typealias PreSignedUploadUrlCompletion = (PreSignedUploadUrlResult) -> Void

public typealias PreSignedUploadUrlUploadResult = Result<Void, RepositoryError>
public typealias PreSignedUploadUrlUploadCompletion = (PreSignedUploadUrlUploadResult) -> Void

public protocol PreSignedUploadUrlRepository {
    func create(fileExtension: String, completion: PreSignedUploadUrlCompletion?)
    func upload(url: URL,
                file: URL,
                inputs: [String: String],
                progress: ((Float) -> ())?,
                completion: PreSignedUploadUrlUploadCompletion?)
}

final class LGPreSignedUploadUrlRepository: PreSignedUploadUrlRepository {

    let dataSource: PreSignedUploadUrlDataSource

    // MARK: - Lifecycle

    init(dataSource: PreSignedUploadUrlDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Create

    func create(fileExtension: String, completion: PreSignedUploadUrlCompletion?) {
        dataSource.create(fileExtension: fileExtension) { result in
            switch result {
            case let .failure(error):
                completion?(PreSignedUploadUrlResult(error: RepositoryError(apiError: error)))
            case let .success(form):
                completion?(PreSignedUploadUrlResult(value: form))
            }
        }
    }

    // MARK: - Upload

    func upload(url: URL,
                file: URL,
                inputs: [String : String],
                progress: ((Float) -> ())?,
                completion: PreSignedUploadUrlUploadCompletion?) {

        guard FileManager.default.fileExists(atPath: file.path) else {
            let error = RepositoryError.internalError(message: "File does not exists at url \(file)")
            completion?(PreSignedUploadUrlUploadResult(error: error))
            return
        }

        dataSource.upload(url: url, inputs: inputs, file: file, progress: progress) { result in
            switch result {
            case let .failure(error):
                completion?(PreSignedUploadUrlUploadResult(error: RepositoryError(apiError: error)))
            case .success:
                completion?(PreSignedUploadUrlUploadResult(value: ()))
            }
        }
    }
}
