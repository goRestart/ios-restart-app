import LGComponents
import Vision
import CoreMedia
import LGCoreKit
import Result
import RxSwift

struct MachineLearningVisionObservation {
    let identifier: String
    let confidence: Double
}

typealias MachineLearningVisionCompletion = ([MachineLearningVisionObservation]?) -> Void

protocol MachineLearningVision {
    func predict(pixelBuffer: CVPixelBuffer, completion: MachineLearningVisionCompletion?)
}

@available(iOS 11.0, *)
final class LGVision: MachineLearningVision {
    static let numberOfObservationsToReturn: Int = 3

    private lazy var model: VNCoreMLModel? = {
        return try? VNCoreMLModel(for: MobileNetLetgov7final().model)
    }()

    // MARK: - Vision prediction
    
    func predict(pixelBuffer: CVPixelBuffer, completion: MachineLearningVisionCompletion?) {
        guard let model = model else {
            completion?(nil)
            return
        }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        let completionHandler : VNRequestCompletionHandler = { (request, error) in
            if let observations = request.results as? [VNClassificationObservation] {
                // The observations appear to be sorted by confidence already, so we
                // take the top X and map them to an array of (String, Double) tuples.
                let topObservations = observations.prefix(through: LGVision.numberOfObservationsToReturn-1)
                    .map { MachineLearningVisionObservation(identifier: $0.identifier, confidence: Double($0.confidence)) }
                completion?(topObservations)
            } else {
                completion?(nil)
            }
        }
        let request = VNCoreMLRequest(model: model, completionHandler: completionHandler)
        request.imageCropAndScaleOption = .centerCrop
        try? requestHandler.perform([request]) // no need to catch, completionHandler will also be called
    }
}
