import XCTest
import Snap
@testable import UI

final class FontableSpec: XCTestCase {

  func test_font_book_is_valid() {
    let fontBook: [(font: UIFont, name: String)] = [
      (.h1, "H1"), (.h2, "H2"), (.button, "button"),
      (.tiny, "tiny"), (.body(.regular), "body_regular"), (.body(.semibold), "body_semibold"),
      (.small(.regular), "small_regular"), (.small(.semibold), "small_semibold")
    ]
    
    fontBook.forEach { element in
      expect(view(with: element.font, named: element.name)).toMatchSnapshot(named: "\(element.name)_font")
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

