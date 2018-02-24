import UI
import Domain
import RxSwift

final class ProductPriceViewController: ViewController {

  private let productPriceView = ProductPriceView()
  private let viewBinder: ProductPriceViewBinder

  var viewModel: ProductPriceViewModelType!

  init(viewBinder: ProductPriceViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  required public init?(coder aDecoder: NSCoder) { fatalError() }

  public override func loadView() {
    self.view = productPriceView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    title = Localize("product_price.title", table: Table.productPrice, in: .framework)
  }

  override public func bindViewModel() {
    viewBinder.bind(view: productPriceView, to: viewModel, using: bag)
  }
}
