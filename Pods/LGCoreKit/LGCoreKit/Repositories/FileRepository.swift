//
//  FileRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 11/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias FilesResult = Result<[File], RepositoryError>
public typealias FilesCompletion = FilesResult -> Void

public typealias FileResult = Result<File, RepositoryError>
public typealias FileCompletion =  FileResult -> Void


public protocol FileRepository {
    func upload(images: [UIImage], progress: ((Float) -> ())?, completion: FilesCompletion?)
    func upload(image: UIImage, progress: (Float -> ())?, completion: FileCompletion?)
}
