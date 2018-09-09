import XCTest
import Snap
import UI
@testable import Listing

final class ProductImagesViewSpec: XCTestCase {
  
  func test_view_snapshot_is_valid() {
    let view = ProductImagesView()
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
  
  func test_should_select_image_1() {
    let view = ProductImagesView()
    
    view.onImageSelected(image: Images.Test.bestGame, with: 1)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
  
  func test_should_select_image_2() {
    let view = ProductImagesView()
    
    view.onImageSelected(image: Images.Test.bestGame, with: 2)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
  
  func test_should_select_image_3() {
    let view = ProductImagesView()
    
    view.onImageSelected(image: Images.Test.bestGame, with: 3)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
  
  func test_should_select_image_4() {
    let view = ProductImagesView()
    
    view.onImageSelected(image: Images.Test.bestGame, with: 4)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
  
  func test_should_select_image_5() {
    let view = ProductImagesView()
    
    view.onImageSelected(image: Images.Test.bestGame, with: 5)
    
    expect(view).toMatchSnapshot(for: [.iPhone5, .iPhone8, .iPhone8Plus])
  }
}
