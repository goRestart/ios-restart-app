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
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) { fatalError() }

  // MARK: - View
  
  private func setupView() {
    tabBar.isTranslucent = false
    tabBar.barTintColor = .white
    tabBar.tintColor = .primary
    delegate = self
  }
  
  private func bindViewModel() {
    viewBinder.bind(view: self, to: viewModel, using: bag)
  }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController,
                        shouldSelect viewController: UIViewController) -> Bool
  {
    let publishIsAskingForSelection = viewController.tabBarItem.tag == MenuItem.publish.rawValue
    if publishIsAskingForSelection {
      return false
    }
    return true
  }
  
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    switch item.tag {
    case MenuItem.publish.rawValue:
      viewModel.input.didTapAddProduct()
    default:
      break
    }
  }
}
