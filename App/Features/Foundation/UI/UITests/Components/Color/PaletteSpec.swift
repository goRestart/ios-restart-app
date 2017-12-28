import XCTest
import Snap
@testable import UI

class PaletteSpec: XCTestCase {

  func test_color_palette_is_valid() {
    let colorPalette: [(UIColor, String)] = [
      (.primary, "primary"), (.primaryAlt, "primary_alt"), (.danger, "danger"),
      (.darkScript, "dark_script"), (.softScript, "soft_script"), (.turquoise, "turquoise"),
      (.pinkishGrey, "pinkish_grey"), (.darkWhite, "dark_white"), (.darkGrey, "dark_grey"),
      (.grease, "grease"), (.softGrey, "soft_grey")
    ]
    
    colorPalette.forEach { element in
      expect(view(with: element.0)).toMatchSnapshot(named: "\(element.1)_color")
    }
  }

  private func view(with color: UIColor) -> UIView {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    view.backgroundColor = color
    return view
  }
}
