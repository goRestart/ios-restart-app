typealias TermsLinks = (title: String, url: URL?)

struct SmokeTestDetail {
    let title: String
    let subtitle: String
    let userAvatarInfo: UserAvatarInfo?
    let imageIcon: UIImage?
    let plans: [SmokeTestSubscriptionPlan]?
    let featuresTitles: [String]
}

struct SmokeTestSubscriptionPlan {
    let title: String
    let subtitle: String
    let isRecomended: Bool
    let trackId: String
}
