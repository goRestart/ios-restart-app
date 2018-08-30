import Domain
import UI

struct PriceFormatter {
  
  private let numberFormatter: NumberFormatter
  
  init(numberFormatter: NumberFormatter) {
    self.numberFormatter = numberFormatter
  }
  
  func format(_ price: Product.Price) -> String {
    guard price.amount > 0 else {
      return Localize("generic.product.free", Table.generic)
    }
    
    numberFormatter.numberStyle = .currency
    numberFormatter.alwaysShowsDecimalSeparator = false
    numberFormatter.currencyCode = price.locale.currencyCode
    
    guard let formatedPrice = numberFormatter.string(from: NSNumber(floatLiteral: price.amount)) else {
      return String(describing: price.amount)
    }
    return formatedPrice
  }
}
