//
//  FileDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 12/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result


typealias FileDataSourceResult = Result<String, ApiError>
typealias FileDataSourceCompletion = (FileDataSourceResult) -> Void

protocol FileDataSource {
    func uploadFile(_ userId: String, data: Data, imageName: String, progress: ((Float) -> ())?,
        completion: FileDataSourceCompletion?)
}
