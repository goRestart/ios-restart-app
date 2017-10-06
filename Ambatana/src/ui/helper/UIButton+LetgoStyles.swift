//
//  UIButton+LetgoStyles.swift
//  LetGo
//
//  Created by Isaac Roldan on 26/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

enum ButtonFontSize {
    case big
    case medium
    case small
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
        case .primary, .postingFlow:
            return UIColor.primaryColor
        case .secondary:
            return UIColor.secondaryColor
        case .terciary:
            return UIColor.terciaryColor
        case .facebook:
            return UIColor.facebookColor
        case .google:
            return UIColor.googleColor
        case .dark:
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
        case .primary, .postingFlow:
            return UIColor.primaryColorHighlighted
        case .secondary:
            return UIColor.secondaryColorHighlighted
        case .terciary:
            return UIColor.terciaryColorHighlighted
        case .facebook:
            return UIColor.facebookColorHighlighted
        case .google:
            return UIColor.googleColorHighlighted
        case .dark:
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
        case .dark:
            return UIColor.lgBlack.withAlphaComponent(0.3)
        case .logout:
            return UIColor.lgBlack.withAlphaComponent(0.05)
        case .darkField, .lightField:
            return backgroundColor.withAlphaComponent(0.3)
        case .postingFlow:
            return UIColor.lgBlack
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
        case .primary, .terciary, .google, .facebook, .dark, .darkField, .lightField, .logout, .postingFlow:
            return false
        case let .secondary(_, withBorder):
            return withBorder
        }
    }

    var sidePadding: CGFloat {
        switch fontSize {
        case .big:
            return 15
        case .medium, .small:
            return 10
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
}

extension UIButton {

    func setState(_ state: ButtonState) {
        switch state {
        case .hidden:
            isHidden = true
        case .enabled:
            isHidden = false
            isEnabled = true
        case .disabled:
            isHidden = false
            isEnabled = false
        }
    }

    func setStyle(_ style: ButtonStyle) {
        guard buttonType == UIButtonType.custom else {
            print("💣 => Styles can only be applied to customStyle Buttons")
            return
        }
        // XCode8 bug ->  http://stackoverflow.com/questions/39380128/ios-10-gm-with-xcode-8-gm-causes-views-to-disappear-due-to-roundedcorners-clip/39380129#39380129
        layoutIfNeeded()
        clipsToBounds = true
        if style.applyCornerRadius {
            layer.cornerRadius = bounds.height/2
        }
        layer.borderWidth = style.withBorder ? 1 : 0
        layer.borderColor = style.titleColor.cgColor

        setBackgroundImage(style.backgroundColor.imageWithSize(CGSize(width: 1, height: 1)), for: .normal)
        setBackgroundImage(style.backgroundColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
                           for: .highlighted)
        setBackgroundImage(style.backgroundColorDisabled.imageWithSize(CGSize(width: 1, height: 1)), for: .disabled)
        adjustsImageWhenHighlighted = false
        
        titleLabel?.font = style.titleFont
        titleLabel?.lineBreakMode = .byTruncatingTail
        setTitleColor(style.titleColor, for: .normal)
        let padding = style.sidePadding

        let left = contentEdgeInsets.left < padding ? padding : contentEdgeInsets.left
        let right = contentEdgeInsets.right < padding ? padding : contentEdgeInsets.right
        contentEdgeInsets = UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }

    func configureWith(uiAction action: UIAction) {
        setTitle(action.text, for: .normal)
        setImage(action.image, for: .normal)
        if let style = action.buttonStyle {
            setStyle(style)
        }
    }
    
    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 4*insetAmount, bottom: 0, right: 4*insetAmount)
    }
}
