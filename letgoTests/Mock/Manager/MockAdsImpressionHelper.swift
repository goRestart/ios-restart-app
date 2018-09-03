@testable import LetGoGodMode

struct MockAdsImpressionConfigurable: AdsImpressionConfigurable {
    var shouldShowAdsForUser: Bool = false
    var ratio: Int = 20
}
