import UIKit
import LGComponents

final class MultiListingPostedHeaderCell: UICollectionReusableView, ReusableCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15.0,
                                       weight: UIFont.Weight.medium)
        return label
    }()
    
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        reset()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    
    // MARK:- Public Methods
    
    func setup(withText text: NSAttributedString,
               alignment: NSTextAlignment) {
        titleLabel.attributedText = text
        titleLabel.textAlignment = alignment
    }
    
    
    // MARK: Layout & Friends

    private func setupConstraints() {
        addSubviewForAutoLayout(titleLabel)
        
        titleLabel.layout(with: self)
            .fillVertical()
            .fillHorizontal(by: Metrics.margin)
    }
    
    private func reset() {
        titleLabel.attributedText = nil
        titleLabel.text = nil
    }
}
