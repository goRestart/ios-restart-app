//
//  UIButton+LetgoStyles.swift
//  LetGo
//
//  Created by Isaac Roldan on 26/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum ButtonFontSize {
    case Big
    case Medium
    case Small
}

enum ButtonStyle {
    case Primary(fontSize: ButtonFontSize)
    case Secondary(fontSize: ButtonFontSize, withBorder: Bool)
    case Terciary
    case Google
    case Facebook
    case Dark(fontSize: ButtonFontSize)
    case Review
    case DarkField
    case LightField
    
    var titleColor: UIColor {
        switch self {
        case .Primary, .Terciary, .Google, .Facebook, .Dark, .Review:
            return UIColor.whiteColor()
        case .Secondary:
            return UIColor.primaryColor
        case .DarkField:
            return UIColor.white
        case .LightField:
            return UIColor.black
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .Primary:
            return UIColor.primaryColor
        case .Secondary:
            return UIColor.secondaryColor
        case .Terciary:
            return UIColor.terciaryColor
        case .Facebook:
            return UIColor.facebookColor
        case .Google:
            return UIColor.googleColor
        case .Dark:
            return UIColor.blackColor().colorWithAlphaComponent(0.3)
        case .Review:
            return UIColor.reviewColor
        case .DarkField:
            return UIColor.white.colorWithAlphaComponent(0.3)
        case .LightField:
            return UIColor.grayLighter
        }
    }
    
    var backgroundColorHighlighted: UIColor {
        switch self {
        case .Primary:
            return UIColor.primaryColorHighlighted
        case .Secondary:
            return UIColor.secondaryColorHighlighted
        case .Terciary:
            return UIColor.terciaryColorHighlighted
        case .Facebook:
            return UIColor.facebookColorHighlighted
        case .Google:
            return UIColor.googleColorHighlighted
        case .Dark:
            return UIColor.blackColor().colorWithAlphaComponent(0.5)
        case .Review:
            return UIColor.reviewColorHighlighted
        case .DarkField, .LightField:
            return backgroundColor.colorWithAlphaComponent(0.3)
        }
    }
    
    var backgroundColorDisabled: UIColor {
        switch self {
        case .Primary:
            return UIColor.primaryColorDisabled
        case .Secondary:
            return UIColor.secondaryColorDisabled
        case .Terciary:
            return UIColor.terciaryColorDisabled
        case .Facebook:
            return UIColor.facebookColorDisabled
        case .Google:
            return UIColor.googleColorDisabled
        case .Dark:
            return UIColor.blackColor().colorWithAlphaComponent(0.3)
        case .Review:
            return UIColor.reviewColorDisabled
        case .DarkField, .LightField:
            return backgroundColor.colorWithAlphaComponent(0.3)
        }
    }
    
    var titleFont: UIFont {
        switch fontSize {
        case .Big:
            return UIFont.bigButtonFont
        case .Medium:
            return UIFont.mediumButtonFont
        case .Small:
            return UIFont.smallButtonFont
        }
    }

    private var fontSize: ButtonFontSize {
        var fontSize = ButtonFontSize.Big
        switch self {
        case let .Primary(size):
            fontSize = size
        case let .Dark(size):
            fontSize = size
        case let .Secondary(size,_):
            fontSize = size
        case .Terciary:
            fontSize = .Big
        case .Google, .Facebook, .DarkField, .LightField:
            fontSize = .Medium
        case .Review:
            fontSize = .Small
        }
        return fontSize
    }
    
    var withBorder: Bool {
        switch self {
        case .Primary, .Terciary, .Google, .Facebook, .Dark, .Review, .DarkField, .LightField:
            return false
        case let .Secondary(_, withBorder):
            return withBorder
        }
    }

    var sidePadding: CGFloat {
        switch fontSize {
        case .Big:
            return 15
        case .Medium, .Small:
            return 10
        }
    }

    var applyCornerRadius: Bool {
        switch self {
        case .Primary, .Secondary, .Terciary, .Google, .Facebook, .Dark, .Review:
            return true
        case .DarkField, .LightField:
            return false
        }
    }
}

enum ButtonState {
    case Hidden
    case Enabled
    case Disabled
}

extension UIButton {

    func setState(state: ButtonState) {
        switch state {
        case .Hidden:
            hidden = true
        case .Enabled:
            hidden = false
            enabled = true
        case .Disabled:
            hidden = false
            enabled = false
        }
    }

    func setStyle(style: ButtonStyle) {
        guard buttonType == UIButtonType.Custom else {
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
        layer.borderColor = style.titleColor.CGColor

        setBackgroundImage(style.backgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        setBackgroundImage(style.backgroundColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
                           forState: .Highlighted)
        setBackgroundImage(style.backgroundColorDisabled.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        
        titleLabel?.font = style.titleFont
        titleLabel?.lineBreakMode = .ByTruncatingTail
        setTitleColor(style.titleColor, forState: .Normal)
        let padding = style.sidePadding
        let left = contentEdgeInsets.left < padding ? padding : contentEdgeInsets.left
        let right = contentEdgeInsets.right < padding ? padding : contentEdgeInsets.right
        contentEdgeInsets = UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }
}
