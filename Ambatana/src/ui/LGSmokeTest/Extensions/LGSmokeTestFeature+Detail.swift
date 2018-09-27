import LGComponents

extension LGSmokeTestFeature {
    func smokeTestDetail(userAvatarInfo: UserAvatarInfo?,
                         featureFlags: FeatureFlaggeable) -> SmokeTestDetail {
        switch self {
        case .clickToTalk:
            return SmokeTestDetail(title: featureName,
                                   subtitle: R.Strings.smoketestDetailDeveloping(R.Strings.clickToTalkSmoketestTitle) + "\n" + R.Strings.smoketestDetailNoCharge,
                                   userAvatarInfo: userAvatarInfo,
                                   imageIcon: R.Asset.IconsButtons.icCloseDark.image,
                                   plans: featureFlags.clickToTalk.plans,
                                   featuresTitles: [R.Strings.clickToTalkSmoketestFeature1,
                                                    R.Strings.clickToTalkSmoketestFeature2,
                                                    R.Strings.clickToTalkSmoketestFeature3])
        }
    }
}
