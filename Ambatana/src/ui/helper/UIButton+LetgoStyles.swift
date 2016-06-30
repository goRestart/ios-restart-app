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
    
    var titleColor: UIColor {
        switch self {
        case .Primary, .Terciary, .Google, .Facebook, .Dark:
            return UIColor.whiteColor()
        case .Secondary:
            return UIColor.primaryColor
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
        }
    }
    
    var titleFont: UIFont {
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
        case .Google, .Facebook:
            fontSize = .Medium
        }
        
        switch fontSize {
        case .Big:
            return UIFont.bigButtonFont
        case .Medium:
            return UIFont.mediumButtonFont
        case .Small:
            return UIFont.smallButtonFont
        }
    }
    
    var withBorder: Bool {
        switch self {
        case .Primary, .Terciary, .Google, .Facebook, .Dark:
            return false
        case let .Secondary(_, withBorder):
            return withBorder
        }
    }
}

extension UIButton {

    func setStyle(style: ButtonStyle) {
        guard buttonType == UIButtonType.Custom else {
            print("💣 => Styles can only be applied to customStyle Buttons")
            return
        }
        
        clipsToBounds = true
        layer.cornerRadius = bounds.height/2
        layer.borderWidth = style.withBorder ? 1 : 0
        layer.borderColor = style.titleColor.CGColor
        
        setBackgroundImage(style.backgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        setBackgroundImage(style.backgroundColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
                           forState: .Highlighted)
        setBackgroundImage(style.backgroundColorDisabled.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        
        titleLabel?.font = style.titleFont
        setTitleColor(style.titleColor, forState: .Normal)
    }
}
