import LGCoreKit
import LGComponents

extension Priceable {
    func priceString(freeModeAllowed: Bool) -> String {
        if freeModeAllowed && price.isFree {
            return R.Strings.productFreePrice
        } else {
            return price.value > 0 ? formattedPrice() :  R.Strings.productNegotiablePrice
        }
    }
}
