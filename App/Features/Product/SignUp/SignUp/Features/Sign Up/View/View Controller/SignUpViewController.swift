import UIKit
import RxCocoa
import RxSwift
import UI

public final class SignUpViewController: ViewController {
  
  private let signUpView = SignUpView()
  
  public override func loadView() {
    self.view = signUpView
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.prefersLargeTitles = true
    title = Localize("signup.title", table: Table.signUp)
  }
  
  override public func bindViewModel() {
    
  }
}
