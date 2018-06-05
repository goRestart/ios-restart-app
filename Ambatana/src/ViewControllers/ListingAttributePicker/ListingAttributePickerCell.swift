import LGComponents

final class ListingAttributePickerCell: UITableViewCell, ReusableCell {
    
    /// Defines a cell style
    ///
    /// - light: Light content, for use on dark backgrounds
    /// - dark: Dark content, for use on light backgrounds
    enum Theme {
        case light
        case dark
        
        var cellHeight: CGFloat {
            switch self {
            case .light: return 70
            case .dark: return 44
            }
        }
        
        var font: UIFont {
            switch self {
            case .light: return UIFont.postingFlowSelectableItem
            case .dark: return UIFont.bigBodyFont
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .light: return UIColor.whiteTextHighAlpha
            case .dark: return .blackTextHighAlpha
            }
        }
        
        var textColorSelected: UIColor {
            switch self {
            case .light: return .white
            case .dark: return .blackText
            }
        }
        
        var checkTintColor: UIColor {
            switch self {
            case .light: return .white
            case .dark: return .primaryColor
            }
        }
        
        var gradientEnabled: Bool {
            switch self {
            case .dark: return false
            case .light: return true
            }
        }
    }
    
    fileprivate let checkMarkSize: CGSize = CGSize(width: 17, height: 12)
    fileprivate var theme: Theme = .light
    
    override var isSelected: Bool {
        didSet {
            isSelected ? select() : deselect()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configures the cell for a specific value. The theme parameter is used here because it is not possible to
    /// reuse a cell and initialize it with custom parameters. The theme will only be applied if it is different
    /// to the currently set.
    func configure(with text: String, theme: Theme) {
        if self.theme != theme {
            self.theme = theme
            setupTheme()
        }
        textLabel?.text = text
    }
    
    fileprivate func select() {
        let image = R.Asset.IconsButtons.icCheckmark.image.withRenderingMode(.alwaysTemplate)
        let checkmark  = UIImageView(frame: CGRect(origin: .zero, size: checkMarkSize))
        checkmark.image = image
        checkmark.tintColor = theme.checkTintColor
        accessoryView = checkmark
        accessoryType = .checkmark
        textLabel?.textColor = theme.textColorSelected
    }
    
    fileprivate func deselect() {
        accessoryType = .none
        accessoryView = nil
        textLabel?.textColor = theme.textColor
    }
}

fileprivate extension ListingAttributePickerCell {
 
    func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        setupTheme()
    }
    
    func setupTheme() {
        textLabel?.font = theme.font
        textLabel?.textColor = theme.textColor
    }
}
