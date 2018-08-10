
import UIKit
import LGComponents

class PostingServicesListingTypeSelectionCell: UITableViewCell, ReusableCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func setupLayout() {
        addSubviewForAutoLayout(titleLabel)
        
        titleLabel.layout(with: self)
            .fillVertical(by: Metrics.shortMargin)
            .fillHorizontal(by: Metrics.margin)
    }
    
    func setup(withPrefixText prefixText: String?,
               nameText: String?) {
        titleLabel.attributedText = buildAttributedTitle(withPrefixText: prefixText, nameText: nameText)
    }
    
    func buildAttributedTitle(withPrefixText prefixText: String?,
                              nameText: String?) -> NSAttributedString? {
        guard let prefixText = prefixText,
            let nameText = nameText else {
                return nil
        }
        
        let string = "\(prefixText) \(nameText)"
        return string.bifontAttributedText(highlightedText: nameText,
                                           mainFont: UIFont.boldSystemFont(ofSize: 23),
                                           mainColour: .grayRegular,
                                           otherFont: UIFont.boldSystemFont(ofSize: 23.0),
                                           otherColour: .serviceTypeRed)
    }
}
