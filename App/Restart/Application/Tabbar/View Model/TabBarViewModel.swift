import RxSwift

struct TabBarViewModel: TabBarViewModelType, TabBarViewModelInput {
  var input: TabBarViewModelInput { return self }
  
  private let tabBarCoordinator: TabBarCoordinator
  
  init(tabBarCoordinator: TabBarCoordinator) {
    self.tabBarCoordinator = tabBarCoordinator
  }
  
  func didTapAddProduct() {
    tabBarCoordinator.openPublishNewProduct()
  }
}
