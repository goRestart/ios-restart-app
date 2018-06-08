import LGComponents

final class PostMultiSelectionCell: UITableViewCell, ReusableCell {

    private var theme: ListingAttributePickerCell.Theme = .light
    
    override var isSelected: Bool {
        didSet {
            isSelected ? select() : deselect()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        accessoryType = .checkmark
        selectionStyle = .none
        backgroundColor = .clear
        textLabel?.font = theme.font
        textLabel?.textColor = theme.textColorSelected
    }

    func configure(with text: String, theme: ListingAttributePickerCell.Theme) {
        textLabel?.text = text
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        deselect()
    }
    
    //  MARK: - Private
    
    private func select() {
        accessoryView = checkBox(selected: true)
    }
    
    private func deselect() {
        accessoryView = checkBox(selected: false)
    }
    
    private func checkBox(selected: Bool) -> UIView {
        let asset = selected ? R.Asset.IconsButtons.icCheckboxSelected : R.Asset.IconsButtons.icCheckbox
        let checkmark  = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: Layout.checkboxSize, height: Layout.checkboxSize)))
        checkmark.image = asset.image
        return checkmark
    }
    
    private struct Layout {
        static let checkboxSize: CGFloat = 24
    }
}
