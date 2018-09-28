import LGComponents

extension LGSmokeTestFeature {
    var subtitle: String {
        switch self {
        case .clickToTalk:
            return R.Strings.smoketestFeedbackSubtitle("\"\(featureName)\"")
        }
    }
    
    var feedbackOptions: [String] {
        switch self {
        case .clickToTalk:
            return [R.Strings.smoketestFeedbackExpensive,
                    R.Strings.smoketestFeedbackOptionNoPhoneCall,
                    R.Strings.smoketestFeedbackOther]
        }
    }
}
