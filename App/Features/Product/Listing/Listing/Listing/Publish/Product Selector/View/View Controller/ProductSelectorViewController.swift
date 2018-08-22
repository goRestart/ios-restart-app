import UI
import Domain

final class ProductSelectorViewController: ViewController {

  var viewModel: ProductSelectorViewModelType!
  
  private let productSelectorView = ProductSelectorView()

  init() { super.init(nibName: nil, bundle: nil) }
  required init?(coder aDecoder: NSCoder) { fatalError() }

 override func loadView() {
    productSelectorView.delegate = self
    self.view = productSelectorView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = Localize("product_selector.title", table: Table.productSelector)
  }
}

// MARK: - ProductSelectorViewDelegate

extension ProductSelectorViewController: ProductSelectorViewDelegate {
  func onGameSelected(with id: Identifier<Game>) {
    viewModel.input.onGameSelected(with: id)
  }
}
