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
    case review
    case darkField
    case lightField
    
    var titleColor: UIColor {
        switch self {
        case .primary, .terciary, .google, .facebook, .dark, .review, .logout:
            return UIColor.white
        case .secondary:
            return UIColor.primaryColor
        case .darkField:
            return UIColor.white
        case .lightField:
            return UIColor.black
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
        case .dark:
            return UIColor.black.withAlphaComponent(0.3)
        case .logout:
            return UIColor.black.withAlphaComponent(0.1)
        case .review:
            return UIColor.reviewColor
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
        case .dark:
            return UIColor.black.withAlphaComponent(0.5)
        case .logout:
            return UIColor.black.withAlphaComponent(0.05)
        case .review:
            return UIColor.reviewColorHighlighted
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
            return UIColor.black.withAlphaComponent(0.3)
        case .logout:
            return UIColor.black.withAlphaComponent(0.05)
        case .review:
            return UIColor.reviewColorDisabled
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
        }
    }

    private var fontSize: ButtonFontSize {
        var fontSize = ButtonFontSize.big
        switch self {
        case let .primary(size):
            fontSize = size
        case let .dark(size):
            fontSize = size
        case .logout:
            fontSize = .medium
        case let .secondary(size,_):
            fontSize = size
        case .terciary:
            fontSize = .big
        case .google, .facebook, .darkField, .lightField:
            fontSize = .medium
        case .review:
            fontSize = .small
        }
        return fontSize
    }
    
    var withBorder: Bool {
        switch self {
        case .primary, .terciary, .google, .facebook, .dark, .review, .darkField, .lightField, .logout:
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
        case .primary, .secondary, .terciary, .google, .facebook, .dark, .review, .logout:
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

        setBackgroundImage(style.backgroundColor.imageWithSize(CGSize(width: 1, height: 1)), for: UIControlState())
        setBackgroundImage(style.backgroundColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
                           for: .highlighted)
        setBackgroundImage(style.backgroundColorDisabled.imageWithSize(CGSize(width: 1, height: 1)), for: .disabled)
        
        titleLabel?.font = style.titleFont
        titleLabel?.lineBreakMode = .byTruncatingTail
        setTitleColor(style.titleColor, for: UIControlState())
        let padding = style.sidePadding
        let left = contentEdgeInsets.left < padding ? padding : contentEdgeInsets.left
        let right = contentEdgeInsets.right < padding ? padding : contentEdgeInsets.right
        contentEdgeInsets = UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }

    func configureWith(uiAction action: UIAction) {
        setTitle(action.text, for: UIControlState())
        setImage(action.image, for: UIControlState())
        if let style = action.buttonStyle {
            setStyle(style)
        }
    }
}
