import UI

final class ProductSummaryViewController: ViewController {
  
  private let productSummaryView = ProductSummaryView()
  
  public override func loadView() {
    self.view = productSummaryView
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError() }
}
