import LGCoreKit
import LGComponents

extension Priceable {
    func priceString() -> String {
        if price.isFree {
            return R.Strings.productFreePrice
        } else {
            return price.value > 0 ? formattedPrice() :  R.Strings.productNegotiablePrice
        }
    }
}
