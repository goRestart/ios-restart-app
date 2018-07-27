import UIKit

class DropdownItemCell: UITableViewCell, ReusableCell {
    
    private enum Layout {
        static let titleLabelFontSize: CGFloat = 17.0
        static let defaultTitleTextColour: UIColor = .blackText
        static let disabledTitleTextColour: UIColor = UIColor.blackText.withAlphaComponent(0.2)
        static let checkboxSize: CGSize = CGSize(width: 16.0, height: 16.0)
        static let checkboxTrailingConstant: CGFloat = 19.0
        static let titleLabelTrailingConstant: CGFloat = 13.0
        static let titleLabelLeadingConstant: CGFloat = 55.0
    }
    
    internal let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Layout.defaultTitleTextColour
        label.font = UIFont.systemFont(ofSize: Layout.titleLabelFontSize)
        label.textAlignment = .left
        
        return label
    }()
    
    internal let checkboxView: LGCheckboxView = LGCheckboxView(withFrame: CGRect.zero,
                                                               state: .deselected)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(withRepresentable representable: DropdownCellRepresentable) {
        titleLabel.text = representable.content.title
        updateState(state: representable.state, animated: false)
    }
    
    func updateState(state: DropdownCellState, animated: Bool) {
        updateTitleLabel(forState: state)
        updateCheckbox(withState: state, animated: animated)
        updateCellState(toState: state)
    }
    
    private func updateCellState(toState state: DropdownCellState) {
        switch state {
        case .selected, .semiSelected:
            isSelected = true
        case .deselected:
            isSelected = false
        }
    }
    
    private func updateTitleLabel(forState state: DropdownCellState) {
        switch state {
        case .selected, .semiSelected, .deselected:
            titleLabel.textColor = Layout.defaultTitleTextColour
        }
    }
    
    private func updateCheckbox(withState state: DropdownCellState, animated: Bool) {
        switch state {
        case .selected:
            checkboxView.update(withState: .selected, animated: animated)
        case .semiSelected:
            checkboxView.update(withState: .semiSelected, animated: animated)
        case .deselected:
            checkboxView.update(withState: .deselected, animated: animated)
        }
    }
    
    
    // MARK: Layout
    
    internal func setupLayout() {
        contentView.addSubviewsForAutoLayout([titleLabel, checkboxView])
        
        checkboxView.layout()
            .width(Layout.checkboxSize.width)
            .height(Layout.checkboxSize.height)
        
        checkboxView.layout(with: contentView)
            .trailing(by: -Layout.checkboxTrailingConstant)
            .centerY()
        
        titleLabel.layout(with: contentView)
            .leading(by: Layout.titleLabelLeadingConstant)
            .fillVertical()
        
        titleLabel.layout(with: checkboxView)
            .trailing(to: .leading, by: -Layout.titleLabelTrailingConstant)
    }
}
