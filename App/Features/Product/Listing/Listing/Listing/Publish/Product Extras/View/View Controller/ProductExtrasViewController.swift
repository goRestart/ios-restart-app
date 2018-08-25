import UI

public final class ProductExtrasViewController: ViewController {
  
  var viewModel: ProductExtrasViewModelType!
  
  private let productExtrasView = ProductExtrasView()
  private let viewBinder: ProductExtrasViewBinder

  init(viewBinder: ProductExtrasViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) { fatalError() }
  
  public override func loadView() {
    self.view = productExtrasView
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.input.viewDidLoad()
  }
  
  public override func bindViewModel() {
    viewBinder.bind(view: productExtrasView, to: viewModel, using: bag)
  }
}
