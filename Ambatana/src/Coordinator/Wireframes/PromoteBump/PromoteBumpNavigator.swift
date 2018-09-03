protocol PromoteBumpNavigator {
    func promoteBumpDidCancel()
    func openSellFaster(listingId: String,
                        bumpUpProductData: BumpUpProductData,
                        typePage: EventParameterTypePage?)
}
