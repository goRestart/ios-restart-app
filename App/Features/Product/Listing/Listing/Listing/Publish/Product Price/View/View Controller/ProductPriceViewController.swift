import UI

final class ProductPriceViewController: ViewController {

  private let productPriceView = ProductPriceView()
  private let viewBinder: ProductPriceViewBinder

  var viewModel: ProductPriceViewModelType!

  init(viewBinder: ProductPriceViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder aDecoder: NSCoder) { fatalError() }

  override func loadView() {
    self.view = productPriceView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    productPriceView.becomeFirstResponder()
  }
  
  override func bindViewModel() {
    viewBinder.bind(view: productPriceView, to: viewModel, using: bag)
  }
}
