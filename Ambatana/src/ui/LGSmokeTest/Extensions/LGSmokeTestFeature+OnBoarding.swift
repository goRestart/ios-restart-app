import LGComponents

extension LGSmokeTestFeature {
    
    var pages: [LGSmokeTestPage] {
        switch self {
        case .clickToTalk:
            return [LGSmokeTestPage(title: featureName,
                                    subtitle: R.Strings.clickToTalkSmoketestSubtitle,
                                    description: R.Strings.clickToTalkSmoketestDescription,
                                    image: R.Asset.Verticals.SmokeTests.ClickToTalk.smokeTestClickToTalkImage.image)]
        }
    }
    
    var actionTitle: String {
        switch self {
        case .clickToTalk:
            return R.Strings.clickToTalkSmoketestActionButton
        }
    }
    
    var smokeTestType: EventParameterSmokeTestType {
        switch self {
        case .clickToTalk:
            return .clickToTalk
        }
    }
}
