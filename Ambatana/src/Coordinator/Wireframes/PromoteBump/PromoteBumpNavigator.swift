protocol PromoteBumpNavigator {
    func promoteBumpDidCancel()
    func openSellFaster(listingId: String,
                        bumpUpProductData: BumpUpProductData,
                        maxCountdown: TimeInterval,
                        typePage: EventParameterTypePage?)
}
