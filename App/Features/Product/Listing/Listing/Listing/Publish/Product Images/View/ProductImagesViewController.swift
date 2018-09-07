import UI

final class ProductImagesViewController: ViewController {

  private let productImagesView = ProductImagesView()
  private let viewBinder: ProductImagesViewBinder
  
  var viewModel: ProductImagesViewModelType!
  
  init(viewBinder: ProductImagesViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  
  override func loadView() {
    self.view = productImagesView
  }
  
  override func bindViewModel() {
    viewBinder.bind(productImagesView, to: viewModel, using: bag)
  }
}
