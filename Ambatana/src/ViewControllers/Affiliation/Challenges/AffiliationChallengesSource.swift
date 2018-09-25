enum AffiliationChallengesSource {
    enum FeedButtonName {
        case icon, banner
    }
    case feed(FeedButtonName)
    case settings
    case external
}
