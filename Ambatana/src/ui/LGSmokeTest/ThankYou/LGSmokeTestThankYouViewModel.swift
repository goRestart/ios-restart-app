import LGComponents

final class LGSmokeTestThankYouViewModel: BaseViewModel {
    
    private let feature: LGSmokeTestFeature
    
    // MARK: - Lifecycle
    
    convenience init(feature: LGSmokeTestFeature) {
        self.init(feature)
    }
    
    init(_ feature: LGSmokeTestFeature) {
        self.feature = feature
        super.init()
    }
    
}

//  MARK: - Input

extension LGSmokeTestThankYouViewModel {
    var subtitle: String { return feature.subtitleThankYou }
    var image: UIImage { return feature.interestImage }
    var color: UIColor { return feature.color }
}
