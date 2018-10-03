import LGComponents

extension LGSmokeTestFeature {
    var tapToActionViewModel: TapToActionViewModel {
        switch self {
        case .clickToTalk:
            return TapToActionViewModel(icon: R.Asset.Verticals.SmokeTests.ClickToTalk.bannerClickToTalk.image,
                                        title: R.Strings.clickToTalkSmoketestBannerTitle)
        }
    }
    
    var tapToActionUIConfiguration: TapToActionUIConfiguration {
        switch self {
        case .clickToTalk:
            return TapToActionUIConfiguration(backgroundColor: UIColor.clickToTalk, titleColor: .white)
        }
    }
}
