//
//  LGMachineLearning.swift
//  LetGo
//
//  Created by Nestor on 06/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import CameraManager
import LGCoreKit
import CoreMedia

typealias MachineLearningStatsPredictionCompletion = ([MachineLearningStats]?) -> Void

/**
 MachineLearning can predict stats in two ways:
 - Live: by capturing via delegate VideoCaptureDelegate. Results are publish into `liveStats`
 - One time: by calling predict(pixelBuffer:completion:). Result is provided in the completion
 */
protocol MachineLearning: VideoOutputDelegate, VideoCaptureDelegate {
    var isLiveStatsEnabled: Bool { get set }
    var liveStats: Variable<[MachineLearningStats]?> { get }
    var pixelsBuffersToForwardPerSecond: Int { get }
    func predict(pixelBuffer: CVPixelBuffer, completion: MachineLearningStatsPredictionCompletion?)
}

final class LGMachineLearning: MachineLearning {
    private let machineLearningRepository: MachineLearningRepository
    private var stats: [MachineLearningStats] {
        return machineLearningRepository.stats
    }
    private var machineLearningVision: MachineLearningVision?
    private let semaphore = DispatchSemaphore(value: 2)
    
    private var canPredict: Bool {
        if #available(iOS 11, *) {
            return machineLearningVision != nil
        }
        return false
    }
    
    var isLiveStatsEnabled: Bool = true
    let pixelsBuffersToForwardPerSecond: Int = 15
    let liveStats = Variable<[MachineLearningStats]?>(nil)

    convenience init() {
        self.init(machineLearningRepository: Core.machineLearningRepository)
    }
    
    init(machineLearningRepository: MachineLearningRepository) {
        self.machineLearningRepository = machineLearningRepository
        if #available(iOS 11, *) {
            machineLearningVision = LGVision.shared
        } else {
            machineLearningVision = nil
        }
        machineLearningRepository.fetchStats(jsonFileName: "MobileNetLetgov7final", completion: nil)
    }

    deinit {
        // Workaround to avoid crashes when deinit
        // and prediction block it's called
        while semaphore.signal() != 0 {}
    }

    func predict(pixelBuffer: CVPixelBuffer, completion: MachineLearningStatsPredictionCompletion?) {
        guard canPredict else {
            completion?(nil)
            return
        }
        machineLearningVision?.predict(pixelBuffer: pixelBuffer) { [weak self] observations in
            guard let observationsValue = observations else {
                completion?(nil)
                return
            }
            let statsResult: [MachineLearningStats] =
                observationsValue.flatMap { [weak self] observation -> MachineLearningStats? in
                    return self?.machineLearningRepository.stats(forKeyword: observation.identifier,
                                                                 confidence: observation.confidence)
            }
            completion?(statsResult)
        }
    }
    
    // MARK: - VideoOutputDelegate & VideoCaptureDelegate
    
    func didCaptureVideoFrame(pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        guard canPredict, isLiveStatsEnabled, let pixelBuffer = pixelBuffer else { return }
        // For better throughput, perform the prediction on a background queue
        // instead of on the CameraManager queue. We use the semaphore to block
        // the capture queue and drop frames when Core ML can't keep up.
        semaphore.wait()
        DispatchQueue.global().async { [weak self] in
            self?.predict(pixelBuffer: pixelBuffer, completion: { stats in
                // Must be dispatched to main thread to prevent two different
                // threads trying to assign the same `Variable.value` unsynchronized.
                DispatchQueue.main.async {
                    self?.liveStats.value = stats
                    self?.semaphore.signal()
                }
            })
        }
    }
}
