import Foundation
import LGComponents

final class FeaturedInfoViewModel: BaseViewModel {

    var titleText: String
    var sellFasterText: String
    var increaseVisibilityText: String
    var moreBuyersText: String

    var navigator: FeaturedInfoNavigator?


    // MARK: - Lifecycle

    override init() {
        self.titleText = R.Strings.featuredInfoViewTitle
        self.sellFasterText = R.Strings.featuredInfoViewSellFaster
        self.increaseVisibilityText = R.Strings.featuredInfoViewIncreaseVisibility
        self.moreBuyersText = R.Strings.featuredInfoViewMoreBuyers
    }


    // MARK: - Public methods

    func closeButtonPressed() {
        navigator?.closeFeaturedInfo()
    }
}
