import LGComponents

extension LGSmokeTestFeature {
    
    var subtitleThankYou: String {
        switch self {
        case .clickToTalk:
            return R.Strings.smoketestDetailDeveloping("\"\(featureName)\"") + " " + R.Strings.smoketestDetailNoCharge
        }
    }
    
    var interestImage: UIImage {
        switch self {
        case .clickToTalk:
            return R.Asset.IconsButtons.icClickToTalk.image
        }
    }
    
}
