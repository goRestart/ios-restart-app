import UI
import Domain

final class ProductSelectorViewController: ViewController {

  var viewModel: ProductSelectorViewModelType!

  init() { super.init(nibName: nil, bundle: nil) }
  required public init?(coder aDecoder: NSCoder) { fatalError() }

  public override func loadView() {
    let view = ProductSelectorView()
    view.delegate = self
    self.view = view
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    title = Localize("product_selector.title", table: Table.productSelector, in: .framework)
  }
}

extension ProductSelectorViewController: ProductSelectorViewDelegate {
  func onGameSelected(with id: Identifier<Game>) {
    viewModel.input.onGameSelected(with: id)
  }
}
