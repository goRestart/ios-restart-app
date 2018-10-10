import LGComponents

typealias Feedback = (title: String, trackId: String)

extension LGSmokeTestFeature {
    var subtitle: String {
        switch self {
        case .clickToTalk:
            return R.Strings.smoketestFeedbackSubtitle("\"\(featureName)\"")
        }
    }
    
    var feedbackOptions: [Feedback] {
        switch self {
        case .clickToTalk:
            return [(title: R.Strings.smoketestFeedbackExpensive, trackId: EventParameterSmokeTestOptions.tooExpensive.rawValue),
                    (title: R.Strings.smoketestFeedbackOptionNoPhoneCall, trackId: EventParameterSmokeTestOptions.dontWantPhoneCalls.rawValue),
                    (title: R.Strings.smoketestFeedbackOther, trackId: EventParameterSmokeTestOptions.other.rawValue)]
        }
    }
}
