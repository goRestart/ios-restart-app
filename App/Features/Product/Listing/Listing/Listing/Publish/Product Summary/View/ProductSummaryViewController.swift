import UI

public final class ProductSummaryViewController: ViewController {
  
  private let productSummaryView = ProductSummaryView()
  
  public override func loadView() {
    self.view = productSummaryView
  }
  
  public init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder aDecoder: NSCoder) { fatalError() }
}
