import UIKit
import RxCocoa
import RxSwift
import UI

final class NotLoggedViewController: ViewController {
  
  var viewModel: NotLoggedViewModelType!
  
  private let notLoggedView = NotLoggedView()
  
  override func loadView() {
    self.view = notLoggedView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func bindViewModel() {
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
