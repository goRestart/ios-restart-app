import UIKit
import RxCocoa
import RxSwift
import UI

final class NotLoggedViewController: ViewController {
  
  var viewModel: NotLoggedViewModelType!
  
  private let notLoggedView = NotLoggedView()
  private let viewBinder: NotLoggedViewBinder

  init(viewBinder: NotLoggedViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError() }
  
  override func loadView() {
    self.view = notLoggedView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func bindViewModel() {
    viewBinder.bind(view: notLoggedView, to: viewModel, using: bag)
  }
}
