import XCTest
import Snap
@testable import UI

class GradientSpec: XCTestCase {
 
  func test_default_gradient_is_valid() {
    expect(view).toMatchSnapshot(named: "default_gradient")
  }
  
  private var view: UIView {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    let gradient = CAGradientLayer.default
    gradient.frame = view.bounds
    view.layer.insertSublayer(gradient, at: 0)
    return view
  }
}
