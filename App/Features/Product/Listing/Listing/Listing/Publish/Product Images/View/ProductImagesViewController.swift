import UI

final class ProductImagesViewController: ViewController {
  private let productImagesView = ProductImagesView()
  
  override func loadView() {
    self.view = productImagesView
  }
}
