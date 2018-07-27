import UIKit

final class DropdownHeaderCell: DropdownItemCell {
    
    private enum Layout {
        static let titleLabelFontSize: Int = 19
        static let checkboxSize: CGSize = CGSize(width: 20.0, height: 20.0)
        static let checkboxTrailingConstant: CGFloat = 17.0
        static let titleLabelTrailingConstant: CGFloat = 23.0
        static let titleLabelLeadingConstant: CGFloat = 10.0
        static let chevronLeadingConstant: CGFloat = 15.0
        static let chevronSize: CGSize = CGSize(width: 18.0, height: 18.0)
    }
    
    private let chevronView: LGChevronView = LGChevronView()
    private var checkboxAction: (() -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel.font = UIFont.systemMediumFont(size: Layout.titleLabelFontSize)
        setupCheckboxTapAction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCheckboxTapAction() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        checkboxView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func didTapCheckbox() {
        checkboxAction?()
    }
    
    func setup(withRepresentable representable: DropdownCellRepresentable,
               isExpanded: Bool,
               showsChevron: Bool,
               checkboxAction: @escaping (() -> Void)) {
        self.checkboxAction = checkboxAction
        let chevronPosition: LGChevronView.Position = isExpanded ? .expanded : .contracted
        updateChevronPosition(toPosition: chevronPosition, showsChevron: showsChevron)
        super.setup(withRepresentable: representable)
    }
    
    func updateChevronPosition(toPosition position: LGChevronView.Position,
                               showsChevron: Bool) {
        chevronView.isHidden = !showsChevron
        chevronView.updatePosition(withPosition: position)
    }
    
    
    // MARK: Layout
    
    override func setupLayout() {
        contentView.addSubviewsForAutoLayout([titleLabel, chevronView, checkboxView])
        
        checkboxView.layout()
            .width(Layout.checkboxSize.width)
            .height(Layout.checkboxSize.height)
        
        checkboxView.layout(with: contentView)
            .trailing(by: -Layout.checkboxTrailingConstant)
            .centerY()
        
        chevronView.layout()
            .width(Layout.chevronSize.width)
            .height(Layout.chevronSize.height)
        chevronView.layout(with: contentView)
            .leading(by: Layout.chevronLeadingConstant)
            .centerY()
        
        titleLabel.layout(with: contentView)
            .fillVertical()
        
        titleLabel.layout(with: chevronView)
            .leading(to: .trailing, by: Layout.titleLabelLeadingConstant)
        
        titleLabel.layout(with: checkboxView)
            .trailing(to: .leading, by: -Layout.titleLabelTrailingConstant)
    }
}
