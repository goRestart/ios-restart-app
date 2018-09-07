import UI

final class ProductSummaryViewController: ViewController {
  
  private let productSummaryView = ProductSummaryView()
  private let viewBinder: ProductSummaryViewBinder
  
  var viewModel: ProductSummaryViewModelType!
  
  init(viewBinder: ProductSummaryViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  
  public override func loadView() {
    self.view = productSummaryView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.input.viewDidLoad()
  }
  
  override func bindViewModel() {
    viewBinder.bind(view: productSummaryView, to: viewModel, using: bag)
  }
}
