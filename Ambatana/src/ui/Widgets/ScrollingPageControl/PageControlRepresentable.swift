
import UIKit

protocol PageControlRepresentable: class {
    var hidesForSinglePage: Bool { get set }
    var currentPageIndicatorTintColor: UIColor? { get set }
    func setup(withNumberOfPages numberOfPages: Int)
    func setCurrentPage(to currentPage: Int, animated: Bool)
}


extension UIPageControl: PageControlRepresentable {
    
    func setup(withNumberOfPages numberOfPages: Int) {
        self.numberOfPages = numberOfPages
    }
    
    func setCurrentPage(to currentPage: Int, animated: Bool) {
        self.currentPage = currentPage
    }
}
