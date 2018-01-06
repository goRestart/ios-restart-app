import UIKit
import UI

public final class LoginViewController: ViewController {
 
  var viewModel: LoginViewModelType!
  
  private let loginView = LoginView()
  private let viewBinder: LoginViewBinder
  
  init(viewBinder: LoginViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  
  required public init?(coder aDecoder: NSCoder) { fatalError() }
  
  public override func loadView() {
    self.view = loginView
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override public func bindViewModel() {
    viewBinder.bind(view: loginView, to: viewModel, using: bag)
  }
}
