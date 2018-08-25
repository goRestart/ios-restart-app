import Foundation

extension Product {
  public struct Price {
    public let amount: Decimal
    public let locale: Locale
    
    public init(amount: Decimal,
                locale: Locale)
    {
      self.amount = amount
      self.locale = locale
    }
  }
}
