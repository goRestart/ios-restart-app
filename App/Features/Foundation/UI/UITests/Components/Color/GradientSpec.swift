import XCTest
import Snap
@testable import UI

final class GradientSpec: XCTestCase {

  func test_default_gradient_is_valid() {
    expect(gradient).toMatchSnapshot(named: "default_gradient")
  }
  
  private var gradient: CAGradientLayer {
    let gradient = CAGradientLayer.default
    gradient.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    return gradient
  }
}
