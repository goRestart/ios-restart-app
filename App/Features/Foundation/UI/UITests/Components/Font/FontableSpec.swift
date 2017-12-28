import XCTest
import Snap
@testable import UI

class FontableSpec: XCTestCase {

  func test_font_book_is_valid() {
    let fontBook: [(UIFont, String)] = [
      (.h1, "H1"), (.h2, "H2"), (.button, "button"),
      (.tiny, "tiny"), (.body(.regular), "body_regular"), (.body(.semibold), "body_semibold"),
      (.small(.regular), "small_regular"), (.small(.semibold), "small_semibold")
    ]
    
    fontBook.forEach { element in
      expect(view(with: element.0, named: element.1)).toMatchSnapshot(named: "\(element.1)_font")
    }
  }
 
  private func view(with font: UIFont, named: String) -> UIView {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
    view.backgroundColor = .white
    
    let label = UILabel(frame: view.bounds)
    label.font = font
    label.text = named
    
    view.addSubview(label)
    return view
  }
}

