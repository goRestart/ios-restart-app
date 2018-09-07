import UIKit
import RxSwift

open class ViewController: UIViewController {
  public let bag = DisposeBag()
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    bindViewModel()
  }
  
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  @available(*, unavailable)
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open func bindViewModel() {}
  
  private func setupView() {
    let backIcon = UIImage(named: "icon.navigation.back", in: .framework, compatibleWith: nil)
    
    navigationController?.navigationBar.backIndicatorImage = backIcon
    navigationController?.navigationBar.backIndicatorTransitionMaskImage = backIcon
    navigationController?.navigationBar.tintColor = .primary
    
    navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
  }
}
