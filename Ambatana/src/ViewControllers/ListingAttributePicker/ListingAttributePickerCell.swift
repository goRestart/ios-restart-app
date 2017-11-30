
final class ListingAttributePickerCell: UITableViewCell {
    
    /// Defines a cell style
    ///
    /// - light: Light content, for use on dark backgrounds
    /// - dark: Dark content, for use on light backgrounds
    enum Theme {
        case light
        case dark
        
        func cellHeight() -> CGFloat {
            switch self {
            case .light: return 70
            case .dark: return 44
            }
        }
        
        func font() -> UIFont {
            switch self {
            case .light: return UIFont.selectableItem
            case .dark: return UIFont.bigBodyFont
            }
        }
        
        func textColor() -> UIColor {
            switch self {
            case .light: return .grayLight
            case .dark: return .blackTextHighAlpha
            }
        }
        
        func checkTintColor() -> UIColor? {
            switch self {
            case .light: return .white
            case .dark: return nil
            }
        }
    }
    
    static let identifier = "\(ListingAttributePickerCell.self)"
    
    fileprivate let checkMarkSize: CGSize = CGSize(width: 17, height: 12)
    fileprivate var theme: Theme = .light
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configures the cell for a specific value. The theme parameter is used here because it is not possible to
    /// reuse a cell and initialize it with custom parameters. The theme will only be applied if it is different
    /// from nil and different to the currently set.
    func configure(with text: String, theme: Theme? = nil) {
        if let theme = theme, self.theme != theme {
            self.theme = theme
            setupTheme()
        }
        textLabel?.text = text
    }
    
    func select() {
        let image = #imageLiteral(resourceName: "ic_checkmark").withRenderingMode(.alwaysTemplate)
        let checkmark  = UIImageView(frame: CGRect(origin: .zero, size: checkMarkSize))
        checkmark.image = image
        if let color = theme.checkTintColor() {
            checkmark.tintColor = color
        }
        accessoryView = checkmark
        accessoryType = .checkmark
        textLabel?.textColor = .white
    }
    
    func deselect() {
        accessoryType = .none
        accessoryView = nil
        textLabel?.textColor = .grayLight
    }
}

fileprivate extension ListingAttributePickerCell {
 
    func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        setupTheme()
    }
    
    func setupTheme() {
        textLabel?.font = theme.font()
        textLabel?.textColor = theme.textColor()
    }
}
