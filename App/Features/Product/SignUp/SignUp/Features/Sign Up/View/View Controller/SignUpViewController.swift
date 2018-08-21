import UIKit
import UI

final class SignUpViewController: ViewController {
  
  var viewModel: SignUpViewModelType!
  
  private let signUpView = SignUpView()
  private let viewBinder: SignUpViewBinder
  
  init(viewBinder: SignUpViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError() }
  
  override func loadView() {
    self.view = signUpView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = Localize("signup.title", table: Table.signUp)
  }

  override func bindViewModel() {
    viewBinder.bind(view: signUpView, to: viewModel, using: bag)
  }
}
