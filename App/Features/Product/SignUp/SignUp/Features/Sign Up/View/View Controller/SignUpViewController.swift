import UIKit
import UI

public final class SignUpViewController: ViewController {
  
  var viewModel: SignUpViewModelType!
  
  private let signUpView = SignUpView()
  private let viewBinder: SignUpViewBinder
  
  init(viewBinder: SignUpViewBinder) {
    self.viewBinder = viewBinder
    super.init(nibName: nil, bundle: nil)
  }
  
  required public init?(coder aDecoder: NSCoder) { fatalError() }
  
  public override func loadView() {
    self.view = signUpView
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  private func configureUI() {
    title = Localize("signup.title", table: Table.signUp)
  }

  override public func bindViewModel() {
    viewBinder.bind(view: signUpView, to: viewModel, using: bag)
  }
}
