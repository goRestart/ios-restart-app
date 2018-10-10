import LGCoreKit
import LGComponents

extension ListingPrice {
    func stringValue(currency: Currency) -> String {
        if isFree {
            return R.Strings.productFreePrice
        } else {
            return value > 0 ? formattedPrice(currency: currency) :  R.Strings.productNegotiablePrice
        }
    }
    
    private func formattedPrice(currency: Currency) -> String {
        let actualCurrencyCode = currency.code
        return Core.currencyHelper.formattedAmountWithCurrencyCode(actualCurrencyCode, amount: value)
    }
}


extension ListingPrice {
    func allowFreeFilters() -> EventParameterBoolean {
        return isFree ? .trueParameter : .falseParameter
    }
}
