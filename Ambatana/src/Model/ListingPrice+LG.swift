import LGCoreKit
import LGComponents

extension ListingPrice {
    func stringValue(currency: Currency, isFreeEnabled: Bool) -> String {
        if isFreeEnabled && isFree {
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
    func allowFreeFilters(freePostingModeAllowed: Bool) -> EventParameterBoolean {
        guard freePostingModeAllowed else { return .notAvailable }
        return isFree ? .trueParameter : .falseParameter
    }
}
