//
//  LetgoButton.swift
//  LetGo
//
//  Created by Facundo Menzella on 09/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

enum ButtonFontSize {
    case big
    case medium
    case small
    case verySmall
}

enum ButtonStyle {
    case primary(fontSize: ButtonFontSize)
    case secondary(fontSize: ButtonFontSize, withBorder: Bool)
    case terciary
    case google
    case facebook
    case dark(fontSize: ButtonFontSize)
    case logout
    case darkField
    case lightField
    case postingFlow
    
    var titleColor: UIColor {
        switch self {
        case .primary, .terciary, .google, .facebook, .dark, .logout, .postingFlow:
            return UIColor.white
        case .secondary:
            return UIColor.primaryColor
        case .darkField:
            return UIColor.white
        case .lightField:
            return UIColor.lgBlack
        }
    }
    
    var backgroundColor: UIColor {
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
        case .dark, .postingFlow:
            return UIColor.lgBlack.withAlphaComponent(0.3)
        case .logout:
            return UIColor.lgBlack.withAlphaComponent(0.1)
        case .darkField:
            return UIColor.white.withAlphaComponent(0.3)
        case .lightField:
            return UIColor.grayLighter
        }
    }
    
    var backgroundColorHighlighted: UIColor {
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
        case .dark, .postingFlow:
            return UIColor.lgBlack.withAlphaComponent(0.5)
        case .logout:
            return UIColor.lgBlack.withAlphaComponent(0.05)
        case .darkField, .lightField:
            return backgroundColor.withAlphaComponent(0.3)
        }
    }
    
    var backgroundColorDisabled: UIColor {
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
        case .dark, .postingFlow:
            return UIColor.lgBlack.withAlphaComponent(0.3)
        case .logout:
            return UIColor.lgBlack.withAlphaComponent(0.05)
        case .darkField, .lightField:
            return backgroundColor.withAlphaComponent(0.3)
        }
    }
    
    var titleFont: UIFont {
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
        case let .primary(size):
            fontSize = size
        case let .dark(size):
            fontSize = size
        case .logout, .postingFlow:
            fontSize = .medium
        case let .secondary(size,_):
            fontSize = size
        case .terciary:
            fontSize = .big
        case .google, .facebook, .darkField, .lightField:
            fontSize = .medium
        }
        return fontSize
    }
    
    var withBorder: Bool {
        switch self {
        case .primary, .terciary, .google, .facebook, .dark, .darkField, .lightField, .logout:
            return false
        case.postingFlow:
            return true
        case let .secondary(_, withBorder):
            return withBorder
        }
    }
    
    
    var borderColor: UIColor {
        switch self {
        case .primary, .terciary, .google, .facebook, .dark, .logout, .darkField:
            return UIColor.white
        case .secondary:
            return UIColor.primaryColor
        case .lightField:
            return UIColor.lgBlack
        case .postingFlow:
            return UIColor.grayBackground
        }
    }
    
    var borderColorDisabled: UIColor {
        switch self {
        case .postingFlow:
            return UIColor.gray
        case .primary, .terciary, .google, .facebook, .dark, .logout, .darkField:
            return UIColor.white
        case .secondary:
            return UIColor.primaryColorDisabled
        case .lightField:
            return UIColor.lgBlack
        }
    }
    
    var titleColorDisabled: UIColor {
        switch self {
        case .postingFlow:
            return UIColor.white
        case .primary, .terciary, .google, .facebook, .dark, .logout, .darkField:
            return UIColor.white
        case .secondary:
            return UIColor.primaryColorDisabled
        case .lightField:
            return UIColor.lgBlack
        }
    }
    
    var sidePadding: CGFloat {
        switch self {
        case .postingFlow:
            return 15
        case .primary, .terciary, .google, .facebook, .dark, .darkField, .lightField, .logout, .secondary:
            switch fontSize {
            case .big:
                return 15
            case .medium, .small, .verySmall:
                return 10
            }
        }
    }
    
    var applyCornerRadius: Bool {
        switch self {
        case .primary, .secondary, .terciary, .google, .facebook, .dark, .logout, .postingFlow:
            return true
        case .darkField, .lightField:
            return false
        }
    }
}

enum ButtonState {
    case hidden
    case enabled
    case disabled
    case loading
}

extension UIButton {
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
final class LetgoButton: UIButton {
    private(set) var style: ButtonStyle = .primary(fontSize: .medium) {
        didSet {
            updateButton(withStyle: style)
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    convenience init(withStyle style: ButtonStyle) {
        self.init(type: .custom)
        updateStyle(style)
    }

    convenience init() { self.init(type: .custom) }

    func setStyle(_ style: ButtonStyle) {
        guard buttonType == UIButtonType.custom else {
            print("💣 => Styles can only be applied to customStyle Buttons")
            return
        }
        updateStyle(style)
    }

    func configureWith(uiAction action: UIAction) {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
}
