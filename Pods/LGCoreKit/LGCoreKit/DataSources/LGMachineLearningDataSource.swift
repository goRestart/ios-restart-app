//
//  MachineLearningDataSource.swift
//  LGCoreKit
//
//  Created by Nestor on 06/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

typealias MachineLearningDataSourceStatsResult = Result<[MachineLearningStats], ApiError>
typealias MachineLearningDataSourceStatsCompletion = (MachineLearningDataSourceStatsResult) -> Void

protocol MachineLearningDataSource {
    func fetchStats(jsonFileName: String, completion: MachineLearningDataSourceStatsCompletion?)
}

class LGMachineLearningDataSource: MachineLearningDataSource {
    func fetchStats(jsonFileName: String, completion: MachineLearningDataSourceStatsCompletion?) {
        if let path = Bundle.letgoAppBundle()?.path(forResource: jsonFileName, ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let stats = try? JSONDecoder().decode([LGMachineLearningStats].self, from: data) {
            completion?(MachineLearningDataSourceStatsResult(value: stats))
        }
        completion?(MachineLearningDataSourceStatsResult(error: ApiError.internalError(description: "could not parse: \(jsonFileName)")))
    }
}
