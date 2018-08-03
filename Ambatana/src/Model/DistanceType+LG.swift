import LGCoreKit
import LGComponents

extension DistanceType {
    
    static func systemDistanceType() -> DistanceType {

        let distanceType: DistanceType
        // use whatever the locale says
        if Locale.current.usesMetricSystem {
            distanceType = .km
        } else {
            distanceType = .mi
        }
        return distanceType
    }
    
    static var allCases: [DistanceType] {
        return [.km, .mi]
    }
    
    func localizedUnitType() -> String {
        switch self {
        case .mi:
            return R.Strings.mileUnitSuffix
        case .km:
            return R.Strings.kilometerUnitSuffix
        }
    }
}
