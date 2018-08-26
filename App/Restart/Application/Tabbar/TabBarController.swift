import UIKit
import RxSwift

final class TabBarController: UITabBarController {

  var viewModel: TabBarViewModelType!
  
  private let bag = DisposeBag()
  private let viewBinder: TabBarViewBinder
  
  init(viewBinder: TabBarViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    bindViewModel()
  }
  
  public required init?(coder aDecoder: NSCoder) { fatalError() }

  // MARK: - View
  
  private func setupView() {
    tabBar.isTranslucent = false
    tabBar.barTintColor = .white
    tabBar.tintColor = .primary
  }
  
  private func bindViewModel() {
    viewBinder.bind(view: self, to: viewModel, using: bag)
  }
}
