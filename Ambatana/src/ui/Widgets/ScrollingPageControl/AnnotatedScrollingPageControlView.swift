
import UIKit
import LGComponents

final class AnnotatedScrollingPageControlView: UIView, PageControlRepresentable {
    
    private struct Layout {
        static let annotationLabelHeightConstant: CGFloat = 26.0
        static let pageControlTopSpacing: CGFloat = Metrics.margin
    }
    
    private struct PageDescriptor: CustomStringConvertible {
        let displayCurrentPage: Int
        let numberOfPages: Int
        
        var description: String {
            return "\(displayCurrentPage)/\(numberOfPages)"
        }
    }
    
    private var pageDescriptor: PageDescriptor {
        return PageDescriptor(displayCurrentPage: pageControl.displayCurrentPage,
                              numberOfPages: pageControl.numberOfPages)
    }
    
    private let annotationLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemMediumFont(size: 13)
        label.cornerRadius = Layout.annotationLabelHeightConstant/2
        label.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return label
    }()
    
    private let pageControl: ScrollingPageControl = {
        let pageControl = ScrollingPageControl(itemColor: .white)
        return pageControl
    }()
    
    var hidesForSinglePage: Bool

    var currentPageIndicatorTintColor: UIColor? {
        didSet {
            pageControl.updateItemColor(to: currentPageIndicatorTintColor)
        }
    }
    
    override init(frame: CGRect) {
        self.hidesForSinglePage = true
        super.init(frame: frame)
        performInitialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("!Ay dios, no me gustan los xibs!")
    }
    
    func setup(withNumberOfPages numberOfPages: Int) {
        pageControl.resetContentOffset()
        pageControl.updateNumberOfPages(to: numberOfPages)
        updateHiddenState(forNumberOfPages: numberOfPages)
    }
    
    func setCurrentPage(to currentPage: Int) {
        pageControl.updateCurrentPage(to: currentPage)
        updateLabelText()
    }
    
    private func updateHiddenState(forNumberOfPages numberOfPages: Int) {
        isHidden = numberOfPages <= 1 && hidesForSinglePage
    }
    
    private func updateLabelText() {
        showLabel()
        annotationLabel.text = pageDescriptor.description
        applyLabelHideAnimation()
    }
    
    private func performInitialSetup() {
        clipsToBounds = false
        addSubviewsForAutoLayout([annotationLabel, pageControl])
        
        NSLayoutConstraint.activate([
            annotationLabel.heightAnchor.constraint(equalToConstant: Layout.annotationLabelHeightConstant),
            annotationLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            annotationLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            annotationLabel.topAnchor.constraint(equalTo: safeTopAnchor),
            pageControl.topAnchor.constraint(equalTo: annotationLabel.bottomAnchor,
                                             constant: Layout.pageControlTopSpacing),
            pageControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            ])
    }
    
    private func applyLabelHideAnimation() {
        UIView.animate(withDuration: 0.25,
                       delay: 3.0,
                       options: .allowAnimatedContent,
                       animations: { [weak self] in
            self?.annotationLabel.alpha = 0
        },
                       completion: nil)
    }
    
    private func showLabel() {
        annotationLabel.alpha = 1
    }
}
