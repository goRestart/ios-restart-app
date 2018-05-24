import UIKit
import LGComponents

protocol FilterRangePriceCellDelegate: class {
    func priceTextFieldValueActive()
    func priceTextFieldValueChanged(_ value: String?, tag: Int)
}

enum TextFieldNumberType: Int {
    case priceFrom = 0
    case priceTo = 1
    case sizeFrom = 2
    case sizeTo = 3
}

class FilterRangePriceCell: UICollectionViewCell, ReusableCell, FilterCell {
    private struct Margins {
        static let standard: CGFloat = 8
    }
    var topSeparator: UIView?
    var bottomSeparator: UIView?
    var rightSeparator: UIView?
    
    let titleLabelFrom = UILabel()
    let titleLabelTo = UILabel()
    let textFieldFrom = UITextField()
    let textFieldTo = UITextField()
    
    weak var delegate: FilterRangePriceCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        resetUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabelFrom)
        titleLabelFrom.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabelTo)
        titleLabelTo.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textFieldFrom)
        textFieldFrom.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textFieldTo)
        textFieldTo.translatesAutoresizingMaskIntoConstraints = false

        addTopSeparator(toContainerView: contentView)
        addBottomSeparator(toContainerView: contentView)
        
        let constraints = [
            titleLabelFrom.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            titleLabelFrom.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.standard),
            titleLabelFrom.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.standard),
            
            textFieldFrom.leadingAnchor.constraint(equalTo: titleLabelFrom.trailingAnchor, constant: Metrics.shortMargin),
            textFieldFrom.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.standard),
            textFieldFrom.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.standard),
            
            titleLabelTo.leadingAnchor.constraint(greaterThanOrEqualTo: textFieldFrom.trailingAnchor, constant: Metrics.shortMargin),
            
            titleLabelTo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.standard),
            titleLabelTo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.standard),
            textFieldTo.leadingAnchor.constraint(equalTo: titleLabelTo.trailingAnchor, constant: Metrics.shortMargin),
            textFieldTo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.standard),
            textFieldTo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.standard),
            textFieldTo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.margin)
        ]
        NSLayoutConstraint.activate(constraints)
        
        titleLabelFrom.font = UIFont.systemFont(size: 16)
        titleLabelFrom.textColor = UIColor.blackText
        textFieldFrom.tintColor = UIColor.primaryColor
        textFieldFrom.placeholder = R.Strings.filtersSectionPrice
        
        titleLabelTo.textColor = UIColor.blackText
        titleLabelTo.font = UIFont.systemFont(size: 16)
        titleLabelTo.tintColor = UIColor.primaryColor
        textFieldTo.placeholder = R.Strings.filtersSectionPrice
        
        textFieldFrom.delegate = self
        textFieldTo.delegate = self
        textFieldFrom.tag = TextFieldNumberType.priceFrom.rawValue
        textFieldTo.tag = TextFieldNumberType.priceTo.rawValue
    }
    
    private func resetUI() {
        textFieldFrom.text = nil
        titleLabelFrom.text = nil
        textFieldTo.text = nil
        titleLabelTo.text = nil
    }
    
    private func setAccessibilityIds() {
        set(accessibilityId: .filterTextFieldIntCell)
        titleLabelFrom.set(accessibilityId:  .filterTextFieldIntCellTitleLabelFrom)
        titleLabelTo.set(accessibilityId:  .filterTextFieldIntCellTitleLabelTo)
        textFieldFrom.set(accessibilityId:  .filterTextFieldIntCellTextFieldFrom)
        textFieldTo.set(accessibilityId:  .filterTextFieldIntCellTextFieldTo)
    }
}

extension FilterRangePriceCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.priceTextFieldValueActive()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField.shouldChangePriceInRange(range, replacementString: string, acceptsSeparator: false) else { return false }
        let updatedText = textField.textReplacingCharactersInRange(range, replacementString: string)
        delegate?.priceTextFieldValueChanged(updatedText, tag: textField.tag)
        return true
    }
}
