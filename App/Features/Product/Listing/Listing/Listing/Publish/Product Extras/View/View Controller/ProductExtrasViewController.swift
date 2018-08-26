import UI

final class ProductExtrasViewController: ViewController {
  
  var viewModel: ProductExtrasViewModelType!
  
  private let productExtrasView = ProductExtrasView()
  private let viewBinder: ProductExtrasViewBinder

  init(viewBinder: ProductExtrasViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) { fatalError() }
  
  override func loadView() {
    self.view = productExtrasView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.input.viewDidLoad()
  }
  
  override func bindViewModel() {
    viewBinder.bind(view: productExtrasView, to: viewModel, using: bag)
  }
}
