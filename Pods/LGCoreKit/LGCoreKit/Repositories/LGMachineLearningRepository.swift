//
//  LGMachineLearningRepository.swift
//  LGCoreKit
//
//  Created by Nestor on 06/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Result

public typealias MachineLearningStatsResult = Result<[MachineLearningStats], RepositoryError>
public typealias MachineLearningStatsCompletion = (MachineLearningStatsResult) -> Void

public protocol MachineLearningRepository {
    var stats: [MachineLearningStats] { get }
    func fetchStats(jsonFileName: String, completion: MachineLearningStatsCompletion?)
    func stats(forKeyword keyword: String, confidence: Double) -> MachineLearningStats?
}

final class LGMachineLearningRepository: MachineLearningRepository {
    let dataSource: MachineLearningDataSource
    var stats: [MachineLearningStats] = []
    
    init(dataSource: MachineLearningDataSource) {
        self.dataSource = dataSource
    }
    
    func fetchStats(jsonFileName: String, completion: MachineLearningStatsCompletion?) {
        dataSource.fetchStats(jsonFileName: jsonFileName) { result in
            if let stats = result.value {
                self.stats = stats
                completion?(MachineLearningStatsResult(value: stats))
            } else if let error = result.error {
                completion?(MachineLearningStatsResult(error: RepositoryError(apiError: error)))
            }
        }
    }
    
    func stats(forKeyword keyword: String, confidence: Double) -> MachineLearningStats? {
        guard let index = stats.index(where: { $0.keyword == keyword }) else { return nil }
        return stats[index].updating(confidence: confidence)
    }
}
