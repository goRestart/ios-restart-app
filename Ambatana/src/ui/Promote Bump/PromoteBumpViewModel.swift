import Foundation
import LGComponents

class PromoteBumpViewModel: BaseViewModel {

    var navigator: PromoteBumpNavigator?
    private var listingId: String
    private var bumpUpProductData: BumpUpProductData
    private var typePage: EventParameterTypePage?

    var titleText: String {
        return R.Strings.promoteBumpTitle
    }

    var sellFasterImage: UIImage? {
        return R.Asset.Monetization.bumpup2X.image
    }
    var sellFasterText: String {
        return R.Strings.promoteBumpSellFasterButton
    }

    var laterText: String {
        return R.Strings.promoteBumpLaterButton
    }


    // MARK: - lifecycle

    init(listingId: String,
         bumpUpProductData: BumpUpProductData,
         typePage: EventParameterTypePage?) {
        self.listingId = listingId
        self.bumpUpProductData = bumpUpProductData
        self.typePage = typePage
    }


    // MARK: - public methods

    func sellFasterButtonPressed() {
        navigator?.openSellFaster(listingId: listingId,
                                  bumpUpProductData: bumpUpProductData,
                                  typePage: typePage)
    }

    func laterButtonPressed() {
        navigator?.promoteBumpDidCancel()
    }
}
