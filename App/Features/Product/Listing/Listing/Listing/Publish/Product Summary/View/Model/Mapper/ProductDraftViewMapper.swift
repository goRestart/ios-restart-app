import Domain
import Core

struct ProductDraftViewMapper: Mappable {
  
  private let priceFormatter: PriceFormatter
  
  init(priceFormatter: PriceFormatter) {
    self.priceFormatter = priceFormatter
  }
  
  func map(_ from: ProductDraft) throws -> ProductDraftUIModel {
    guard let title = from.title,
      let description = from.description,
      let price = from.price else {
      throw MappableError.invalidInput
    }
    return ProductDraftUIModel(
      price: priceFormatter.format(price),
      title: title,
      description: description,
      images: []
    )
  }
}
