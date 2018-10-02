import LGComponents

enum LGSmokeTestFeature {
    case clickToTalk
}

extension LGSmokeTestFeature {
    var featureName: String {
        switch self {
        case .clickToTalk:
            return R.Strings.clickToTalkSmoketestTitle
        }
    }
    
    var color: UIColor {
        switch self {
        case .clickToTalk:
            return .clickToTalk
        }
    }
    
    var testType: EventParameterSmokeTestType {
        switch self {
        case .clickToTalk:
            return .clickToTalk
        }
    }
}
