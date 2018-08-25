import Core
import Listing
import UI

protocol TabBarControllerProvider {
  func makeTabBarController() -> TabBarController
}

extension Assembly: TabBarControllerProvider {
  func makeTabBarController() -> TabBarController {
    let tabBarController = TabBarController(
      viewBinder: viewBinder
    )
    tabBarController.viewModel = viewModel(with: tabBarController)
    tabBarController.rs_setViewControllers(tabBarViewControllers, animated: true)
    return tabBarController
  }
  
  private func viewModel(with controller: TabBarController) -> TabBarViewModelType {
    return TabBarViewModel(
      tabBarCoordinator: tabBarCoordinator(with: controller)
    )
  }
  
  private var viewBinder: TabBarViewBinder {
    return TabBarViewBinder()
  }

  private func tabBarCoordinator(with controller: TabBarController) -> TabBarCoordinator {
    let coordinator = TabBarCoordinator(
      listingProvider: self
    )
    coordinator.tabBarController = controller
    return coordinator
  }
}
