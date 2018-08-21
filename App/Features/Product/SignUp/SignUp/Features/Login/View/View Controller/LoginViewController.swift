import UIKit
import UI

final class LoginViewController: ViewController {
 
  var viewModel: LoginViewModelType!
  
  private let loginView = LoginView()
  private let viewBinder: LoginViewBinder
  
  init(viewBinder: LoginViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError() }
  
  override func loadView() {
    self.view = loginView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = Localize("login.title", table: Table.login)
  }
  
  override func bindViewModel() {
    viewBinder.bind(view: loginView, to: viewModel, using: bag)
  }
}
