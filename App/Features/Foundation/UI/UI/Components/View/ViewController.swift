import UIKit
import RxSwift

open class ViewController: UIViewController {
  public let bag = DisposeBag()
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
  }
  
  open func bindViewModel() {}
}
