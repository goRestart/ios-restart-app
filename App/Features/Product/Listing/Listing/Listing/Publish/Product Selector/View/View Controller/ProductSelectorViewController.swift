import UI
import Domain

final class ProductSelectorViewController: ViewController {

  var viewModel: ProductSelectorViewModelType!

  init() { super.init(nibName: nil, bundle: nil) }
  public required init?(coder aDecoder: NSCoder) { fatalError() }

  override func loadView() {
    let view = ProductSelectorView()
    view.delegate = self
    self.view = view
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
