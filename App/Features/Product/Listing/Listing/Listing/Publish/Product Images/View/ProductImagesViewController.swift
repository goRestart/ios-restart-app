import UI

final class ProductImagesViewController: ViewController {

  fileprivate let productImagesView = ProductImagesView()
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

// MARK: - ProductImagesCoordinatorIndex

extension ProductImagesViewController: ProductImagesCoordinatorIndex {
  func didSelectImage(_ image: UIImage, with index: Int) {
    viewModel.input.onAdd(image: image, with: index)
    productImagesView.onImageSelected(image: image, with: index)
  }
}
