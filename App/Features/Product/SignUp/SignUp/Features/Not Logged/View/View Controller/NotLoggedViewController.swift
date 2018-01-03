import UIKit
import RxCocoa
import RxSwift
import UI

public final class NotLoggedViewController: ViewController {
 
  private let notLoggedView = NotLoggedView()
  
  public override func loadView() {
    self.view = notLoggedView
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override public func bindViewModel() {
 
  }
}
