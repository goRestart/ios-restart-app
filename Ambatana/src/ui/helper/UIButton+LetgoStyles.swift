//
//  UIButton+LetgoStyles.swift
//  LetGo
//
//  Created by Isaac Roldan on 26/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UIButton {
    
    enum ButtonStyle {
        case Primary
        case Secondary
        case Terciary
        case Google
        case Facebook
        case Dark
        
        var titleColor: UIColor {
            switch self {
            case .Primary, .Terciary, .Google, .Facebook, .Dark:
                return UIColor.whiteColor()
            case .Secondary:
                return StyleHelper.primaryColor
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
            return UIFont.bigButtonFont
        }
    }
    
    func setStyle(style: ButtonStyle) {
        guard buttonType == UIButtonType.Custom else {
            print("💣 => Styles can only be applied to customStyle Buttons")
            return
        }
        
        clipsToBounds = true
        layer.cornerRadius = bounds.height/2
        
        setBackgroundImage(style.backgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        setBackgroundImage(style.backgroundColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
                           forState: .Highlighted)
        setBackgroundImage(style.backgroundColorDisabled.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        
        titleLabel?.font = style.titleFont
        setTitleColor(style.titleColor, forState: .Normal)
    }
}