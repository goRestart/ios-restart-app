import Domain

final class ProductDraftSpy: ProductDraftUseCase {
  var saveImagesWasCalled = false
  var saveTitleWasCalled = false
  var saveDescriptionWasCalled = false
  var savePriceWasCalled = false
  var saveProductExtrasWasCalled = false
  var clearWasCalled = false
  var getProductDraftWasCalled = false
  
  func save(images: [UIImage]) {
    saveImagesWasCalled = true
  }
  
  func save(with title: String, productId: Identifier<Product>) {
    saveTitleWasCalled = true
  }
  
  func save(description: String) {
    saveDescriptionWasCalled = true
  }
  
  func save(price: Double) {
    savePriceWasCalled = true
  }
  
  func save(productExtras: [Identifier<Product.Extra>]) {
    saveProductExtrasWasCalled = true
  }
  
  func clear() {
    clearWasCalled = true
  }
  
  func get() -> ProductDraft {
    getProductDraftWasCalled = true
    fatalError()
  }
}

