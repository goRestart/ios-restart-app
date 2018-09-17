typealias SellAction = (String, BumpUpProductData, TimeInterval, EventParameterTypePage?) -> ()

final class PromoteBumpModalWireframe: PromoteBumpNavigator {
    private let root: UIViewController
    private var sellAction: SellAction?

    init(root: UIViewController, sellAction: SellAction?) {
        self.root = root
        self.sellAction = sellAction
    }

    func promoteBumpDidCancel() {
        root.dismiss(animated: true, completion: nil)
    }
    
    func openSellFaster(listingId: String,
                        bumpUpProductData: BumpUpProductData,
                        maxCountdown: TimeInterval,
                        typePage: EventParameterTypePage?) {
        // This callback is just temporary, it should be deleted when the
        // App coordinator disappear 🤞.
        sellAction?(listingId, bumpUpProductData, maxCountdown, typePage);
    }
}
