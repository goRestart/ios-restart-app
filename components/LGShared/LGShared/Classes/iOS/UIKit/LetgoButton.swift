import Foundation

public enum ButtonFontSize {
    case big
    case medium
    case small
    case verySmall
}

public enum ButtonStyle {
    case primary(fontSize: ButtonFontSize)
    case secondary(fontSize: ButtonFontSize, withBorder: Bool)
    case terciary
    case google
    case facebook
    case dark(fontSize: ButtonFontSize, withBorder: Bool)
    case logout
    case darkField
    case lightField
    case postingFlow
    case pinkish(fontSize: ButtonFontSize, withBorder: Bool)
    case transparent(fontSize: ButtonFontSize, sidePadding: CGFloat)
    
    public var titleColor: UIColor {
        switch self {
        case .primary, .terciary, .google, .facebook, .dark, .logout, .postingFlow, .transparent:
            return UIColor.white
        case .secondary:
            return UIColor.primaryColor
        case .darkField:
            return UIColor.white
        case .lightField:
            return UIColor.lgBlack
        case .pinkish:
            return UIColor.pinkText
        }
    }
    
    public var backgroundColor: UIColor {
        switch self {
        case .primary:
            return UIColor.primaryColor
        case .secondary:
            return UIColor.secondaryColor
        case .terciary:
            return UIColor.terciaryColor
        case .facebook:
            return UIColor.facebookColor
        case .google:
            return UIColor.googleColor
        case .dark, .postingFlow, .transparent:
            return UIColor.lgBlack.withAlphaComponent(0.3)
        case .logout:
            return UIColor.lgBlack.withAlphaComponent(0.1)
        case .darkField:
            return UIColor.white.withAlphaComponent(0.3)
        case .lightField:
            return UIColor.grayLighter
        case .pinkish:
            return UIColor.clear
        }
    }
    
    public var backgroundColorHighlighted: UIColor {
        switch self {
        case .primary:
            return UIColor.primaryColorHighlighted
        case .secondary:
            return UIColor.secondaryColorHighlighted
        case .terciary:
            return UIColor.terciaryColorHighlighted
        case .facebook:
            return UIColor.facebookColorHighlighted
        case .google:
            return UIColor.googleColorHighlighted
        case .dark, .postingFlow, .pinkish, .transparent:
            return UIColor.lgBlack.withAlphaComponent(0.5)
        case .logout:
            return UIColor.lgBlack.withAlphaComponent(0.05)
        case .darkField, .lightField:
            return backgroundColor.withAlphaComponent(0.3)
        }
    }
    
    public var backgroundColorDisabled: UIColor {
        switch self {
        case .primary:
            return UIColor.primaryColorDisabled
        case .secondary:
            return UIColor.secondaryColorDisabled
        case .terciary:
            return UIColor.terciaryColorDisabled
        case .facebook:
            return UIColor.facebookColorDisabled
        case .google:
            return UIColor.googleColorDisabled
        case .dark, .postingFlow, .pinkish, .transparent:
            return UIColor.lgBlack.withAlphaComponent(0.3)
        case .logout:
            return UIColor.lgBlack.withAlphaComponent(0.05)
        case .darkField, .lightField:
            return backgroundColor.withAlphaComponent(0.3)
        }
    }
    
    public var titleFont: UIFont {
        switch fontSize {
        case .big:
            return UIFont.bigButtonFont
        case .medium:
            return UIFont.mediumButtonFont
        case .small:
            return UIFont.smallButtonFont
        case .verySmall:
            return UIFont.verySmallButtonFont
        }
    }
    
    private var fontSize: ButtonFontSize {
        var fontSize = ButtonFontSize.big
        switch self {
        case let .primary(size), let .transparent(size, _):
            fontSize = size
        case .logout, .postingFlow:
            fontSize = .medium
        case let .secondary(size, _), let .dark(size, _), let .pinkish(size, _):
            fontSize = size
        case .terciary:
            fontSize = .big
        case .google, .facebook, .darkField, .lightField:
            fontSize = .medium
        }
        return fontSize
    }
    
    public var withBorder: Bool {
        switch self {
        case .primary, .terciary, .google, .facebook, .darkField, .lightField, .logout:
            return false
        case .postingFlow, .transparent:
            return true
        case let .secondary(_, withBorder), let .dark(_, withBorder), let .pinkish(_, withBorder):
            return withBorder
        }
    }
    
    
    public var borderColor: UIColor {
        switch self {
        case .primary, .terciary, .google, .facebook, .dark, .logout, .darkField, .transparent:
            return UIColor.white
        case .secondary:
            return UIColor.primaryColor
        case .lightField:
            return UIColor.lgBlack
        case .postingFlow:
            return UIColor.grayBackground
        case .pinkish:
            return UIColor.pinkText
        }
    }
    
    public var borderColorDisabled: UIColor {
        switch self {
        case .postingFlow, .pinkish, .transparent:
            return UIColor.gray
        case .primary, .terciary, .google, .facebook, .dark, .logout, .darkField:
            return UIColor.white
        case .secondary:
            return UIColor.primaryColorDisabled
        case .lightField:
            return UIColor.lgBlack
        }
    }
    
    public var titleColorDisabled: UIColor {
        switch self {
        case .primary, .terciary, .google, .facebook, .dark, .logout, .darkField, .postingFlow, .pinkish:
            return UIColor.white
        case .secondary:
            return UIColor.primaryColorDisabled
        case .lightField:
            return UIColor.lgBlack
        case .transparent:
            return UIColor.gray
        }
    }
    
    public var sidePadding: CGFloat {
        switch self {
        case .postingFlow:
            return 15
        case .primary, .terciary, .google, .facebook, .dark, .darkField, .lightField, .logout, .secondary, .pinkish:
            switch fontSize {
            case .big:
                return 15
            case .medium, .small, .verySmall:
                return 10
            }
        case .transparent(_, let side):
            return side
        }
    }
    
    public var applyCornerRadius: Bool {
        switch self {
        case .primary, .secondary, .terciary, .google, .facebook, .dark, .logout, .postingFlow, .pinkish, .transparent:
            return true
        case .darkField, .lightField:
            return false
        }
    }
}

public enum ButtonState {
    case hidden
    case enabled
    case disabled
    case loading
}

public extension UIButton {
    func setState(_ state: ButtonState) {
        switch state {
        case .hidden:
            isHidden = true
        case .enabled:
            isHidden = false
            isEnabled = true
        case .disabled, .loading:
            isHidden = false
            isEnabled = false
        }
    }

    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 4*insetAmount, bottom: 0, right: 4*insetAmount)
    }
}
// If you use it with xibs, you must set the type of the button to CUSTOM
public final class LetgoButton: UIButton {
    private(set) var style: ButtonStyle = .primary(fontSize: .medium) {
        didSet {
            updateButton(withStyle: style)
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    convenience public init(withStyle style: ButtonStyle) {
        self.init(type: .custom)
        updateStyle(style)
    }

    convenience public init() { self.init(type: .custom) }

    public func setStyle(_ style: ButtonStyle) {
        guard buttonType == UIButtonType.custom else {
            print("💣 => Styles can only be applied to customStyle Buttons")
            return
        }
        updateStyle(style)
    }

    public func configureWith(uiAction action: UIAction) {
        setTitle(action.text, for: .normal)
        setImage(action.image, for: .normal)
        if let style = action.buttonStyle {
            setStyle(style)
        }
        invalidateIntrinsicContentSize()
    }

    private func updateStyle(_ style: ButtonStyle) {
        self.style = style
    }

    private func updateButton(withStyle style: ButtonStyle) {
        updateLayer(withStyle: style)
        updateBackgroundImage(withStyle: style)
        updateTitleLabel(withStyle: style)
        updateContentEdgeInsets(withStyle: style)
    }

    private func updateLayer(withStyle style: ButtonStyle) {
        clipsToBounds = true
        layer.borderWidth = style.withBorder ? 1 : 0
        layer.borderColor = isEnabled ? style.borderColor.cgColor : style.borderColorDisabled.cgColor
    }

    private func updateBackgroundImage(withStyle style: ButtonStyle) {
        setBackgroundImage(style.backgroundColor.imageWithSize(CGSize(width: 1, height: 1)), for: .normal)
        setBackgroundImage(style.backgroundColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
                           for: .highlighted)
        setBackgroundImage(style.backgroundColorDisabled.imageWithSize(CGSize(width: 1, height: 1)), for: .disabled)
        adjustsImageWhenHighlighted = false
    }

    private func updateTitleLabel(withStyle style: ButtonStyle) {
        titleLabel?.font = style.titleFont
        titleLabel?.lineBreakMode = .byTruncatingTail
        setTitleColor(style.titleColor, for: .normal)
        setTitleColor(style.titleColorDisabled, for: .disabled)
    }

    private func updateContentEdgeInsets(withStyle style: ButtonStyle) {
        let padding = style.sidePadding
        let left = contentEdgeInsets.left < padding ? padding : contentEdgeInsets.left
        let right = contentEdgeInsets.right < padding ? padding : contentEdgeInsets.right
        contentEdgeInsets = UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }
    
    private func updateCornerRadius() {
        if style.applyCornerRadius {
            setRoundedCorners()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
}
