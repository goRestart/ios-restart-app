import Foundation

protocol TabBarViewModelInput {
  func didTapAddProduct()
}

protocol TabBarViewModelType {
  var input: TabBarViewModelInput { get }
}
