
import UIKit

final class MultiListingPostedIncentivisorCell: UICollectionViewCell, ReusableCell {
    
    private let postIncentivisorView: PostIncentivatorView? = {
        return PostIncentivatorView.postIncentivatorView(true,
                                                         isServicesListing: true)
    }()
    
    private var tapAction: (() -> Void)?
    
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupPostIncentivisorView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- Public Methods
    
    func setup(isFreePosting freePosting: Bool,
               withTapAction tapAction: @escaping (() -> Void)) {
        self.tapAction = tapAction
        postIncentivisorView?.isFree = freePosting
        postIncentivisorView?.setupIncentiviseView()
    }
    
    
    // MARK:- Layout & Friends
    
    private func setupPostIncentivisorView() {
        postIncentivisorView?.delegate = self
        postIncentivisorView?.set(accessibilityId: .postingInfoIncentiveContainer)
    }
    
    private func setupConstraints() {
        guard let postIncentivisorView = postIncentivisorView else {
            return
        }
        addSubviewForAutoLayout(postIncentivisorView)
        
        postIncentivisorView.layout(with: self)
            .fillHorizontal()
            .fillVertical(by: Metrics.veryBigMargin*2)
    }
}


// MARK: PostIncentivisorView Delegate

extension MultiListingPostedIncentivisorCell: PostIncentivatorViewDelegate {
    
    func incentivatorTapped() {
        tapAction?()
    }
}
