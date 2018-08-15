import UIKit

protocol FilterPriceCellDelegate: class {
    func priceTextFieldValueActive()
    func priceTextFieldValueChanged(_ value: String?, tag: Int)
}

enum TextFieldNumberType: Int {
    case priceFrom = 0
    case priceTo = 1
    case sizeFrom = 2
    case sizeTo = 3
}

class FilterTextFieldIntCell: UICollectionViewCell, FilterCell, ReusableCell {
    var topSeparator: UIView?
    var bottomSeparator: UIView?
    var rightSeparator: UIView?
    
    
    let titleLabel = UILabel()
    let textField = UITextField()
    
    weak var delegate: FilterPriceCellDelegate?
    
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
        backgroundColor = .white
        addTopSeparator(toContainerView: contentView)
        addBottomSeparator(toContainerView: contentView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(size: 16)
        titleLabel.textColor = UIColor.lgBlack
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            
            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ]
        NSLayoutConstraint.activate(constraints)
        
        textField.tintColor = UIColor.primaryColor
        textField.delegate = self
        textField.textAlignment = .left
        textField.keyboardType = .decimalPad
    }
    
    private func resetUI() {
        textField.text = nil
        titleLabel.text = nil
    }
    
    private func setAccessibilityIds() {
        set(accessibilityId:  .filterTextFieldIntCell)
        titleLabel.set(accessibilityId:  .filterTextFieldIntCellTitleLabel)
        textField.set(accessibilityId:  .filterTextFieldIntCellTextField)
    }
}

extension FilterTextFieldIntCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.priceTextFieldValueActive()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField.shouldChangePriceInRange(range, replacementString: string, acceptsSeparator: false) else { return false }
        let updatedText = textField.textReplacingCharactersInRange(range, replacementString: string)
        delegate?.priceTextFieldValueChanged(updatedText, tag: tag)
        return true
    }
}
