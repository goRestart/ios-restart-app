protocol PromoteBumpNavigator {
    func promoteBumpDidCancel()
    func openSellFaster(listingId: String,
                        purchases: [BumpUpProductData],
                        maxCountdown: TimeInterval,
                        typePage: EventParameterTypePage?)
}
