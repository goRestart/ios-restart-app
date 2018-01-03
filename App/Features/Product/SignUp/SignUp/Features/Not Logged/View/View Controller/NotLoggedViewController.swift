import UIKit
import RxCocoa
import RxSwift
import UI

public final class NotLoggedViewController: ViewController {
  
  var viewModel: NotLoggedViewModelType!
  
  private let notLoggedView = NotLoggedView()
  
  public override func loadView() {
    self.view = notLoggedView
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override public func bindViewModel() {
    notLoggedView.signInButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        self?.viewModel.input.signInButtonPressed()
      })
      .disposed(by: bag)
    
    notLoggedView.signUpButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        self?.viewModel.input.signUpButtonPressed()
      })
      .disposed(by: bag)
  }
}
