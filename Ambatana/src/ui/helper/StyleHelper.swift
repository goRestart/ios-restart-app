//
//  StyleHelper.swift
//  LetGo
//
//  Created by AHL on 27/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import Foundation

class StyleHelper {

    // Colors
    static var primaryColor: UIColor { return StyleHelper.red }
    static var primaryColorHighlighted: UIColor { return StyleHelper.highlightedRed }

    private static let red = UIColor(rgb: 0xFF3F55)
    private static let highlightedRed = UIColor(rgb: 0xFE6E7F)
    
    private static let black = UIColor(rgb: 0x000000)
    private static let gray21 = UIColor(rgb: 0x212121)
    private static let gray44 = UIColor(rgb: 0x2c2c2c)
    private static let gray75 = UIColor(rgb: 0x757575)
    private static let gray153 = UIColor(rgb: 0x999999)
    private static let gray204 = UIColor(rgb: 0xCCCCCC)
    private static let gray213 = UIColor(rgb: 0xD5D5D5)
    private static let gray222 = UIColor(rgb: 0xDEDEDE)
    private static let gray225 = UIColor(rgb: 0xE1E1E1)
    private static let gray235 = UIColor(rgb: 0xEBEBEB)
    private static let gray238 = UIColor(rgb: 0xEEEEEE)
    private static let gray245 = UIColor(rgb: 0xF5F5F5)
    private static let white = UIColor(rgb: 0xFFFFFF)
    
    // > Palette
    private static let grayMedium = UIColor(rgb: 0xD5D3D3)
    private static let grayLight = UIColor(rgb: 0xE9E5E5)
    private static let brownDark = UIColor(rgb: 0xBBA298)
    private static let cream = UIColor(rgb: 0xF3F1EC)
    private static let brownLight = UIColor(rgb: 0xE9E2D7)
    private static let brownMedium = UIColor(rgb: 0xD8CAB7)
    private static let greenMedium = UIColor(rgb: 0xC7C8B5)
    private static let turquoise = UIColor(rgb: 0x179BAA)
    private static let blue = UIColor(rgb: 0x0092D4)
    private static let blueDark = UIColor(rgb: 0x007CB1)
    
    // Fonts
    private static func helveticaNeueFont(size size: Int) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: CGFloat(size))!
    }
    
    private static func helveticaNeueMediumFont(size size: Int) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: CGFloat(size))!
    }
    
    private static func helveticaNeueBoldFont(size size: Int) -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: CGFloat(size))!
    }
    
    private static func helveticaNeueItalicFont(size size: Int) -> UIFont {
        return UIFont(name: "HelveticaNeue-Italic", size: CGFloat(size))!
    }

    // Corners
    static let defaultCornerRadius: CGFloat = 4
    static var buttonCornerRadius: CGFloat { return StyleHelper.defaultCornerRadius }
    
    // state-depending features
    private static let disabledItemAlpha : CGFloat = 0.32
    
    private static let palette = [grayMedium, grayLight, brownDark, cream, brownLight, brownMedium, greenMedium]
    
    // MARK: - Common
    
    static var lineColor: UIColor {
        return gray204
    }
    
    static var darkLineColor: UIColor {
        return gray153
    }
    

    static var disabledButtonBackgroundColor: UIColor {
        return  red //gray204
    }

    static var emptypictureCellBackgroundColor: UIColor {
        return gray225
    }
    
    static var soldColor: UIColor {
        return turquoise
    }
    
    static var standardTextColor: UIColor {
        return gray44
    }
    
    static var onePixelSize: CGFloat {
        return 1 / UIScreen.mainScreen().scale
    }

    // MARK: - NavBar
    
    static var navBarButtonsColor: UIColor {
        return ABTests.navBarTintColor.colorValue
    }
    
    static var navBarTitleColor: UIColor {
        return gray44
    }
    
    static var navBarTitleFont: UIFont {
        return helveticaNeueMediumFont(size: 17)
    }
    
    static var navBarBgImage: UIImage {
        return white.imageWithSize(CGSize(width: 1, height: 1)).applyBlurWithRadius(10, tintColor: nil, saturationDeltaFactor: 0, maskImage: nil)
    }
    
    static var navBarShadowImage: UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale);
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, lineColor.CGColor);
        let fillRect = CGRect(x: 0, y: 0, width: 1, height: 1)  // height: 0.5)
        CGContextFillRect(context, fillRect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    
    static var navBarSearchFieldBgColor: UIColor {
        return UIColor.whiteColor()
    }
    
    static var navBarSearchBorderColor: UIColor {
        return UIColor(rgb: 0xaeaaab)
    }
    
    // MARK: - TabBar
    
    static var tabBarIconSelectedColor: UIColor {
        return red
    }
    
    static var tabBarIconUnselectedColor: UIColor {
        return gray21
    }
    
    static var tabBarSellIconBgColor: UIColor {
        return red
    }
    
    static var tabBarTooltipBgColor: UIColor {
        return red
    }
    
    static var tabBarTooltipTextColor: UIColor {
        return white
    }
    
    static var tabBarTooltipTextFont: UIFont {
        return helveticaNeueBoldFont(size: 16)
    }
    
    // MARK: - Filter Tag
    static var filterTagFont : UIFont {
        return helveticaNeueFont(size: 14)
    }
    
    // MARK: - Product Cell
    
    static var productCellBgColor: UIColor {
        return palette[Int(arc4random_uniform(UInt32(palette.count)))]
    }
    
    // MARK: - Conversation Cell
    
    static var badgeBgColor: UIColor {
        return red
    }
    
    // MARK: - Chat
    
    static var chatOthersBubbleBgColor: UIColor {
        return white
    }
    
    static var chatOthersBubbleBgColorSelected: UIColor {
        return gray238
    }
    
    static var chatMyBubbleBgColor: UIColor {
        return blue
    }
    
    static var chatMyBubbleBgColorSelected: UIColor {
        return blueDark
    }
    
    static var chatTableViewBgColor: UIColor {
        return gray245
    }
    
    static var chatSendButtonFont: UIFont {
        return helveticaNeueMediumFont(size: 15)
    }
    
    static var chatProductViewNameFont: UIFont {
        return helveticaNeueFont(size: 16)
    }
    
    static var chatProductViewUserFont: UIFont {
        return helveticaNeueFont(size: 14)
    }
    
    static var chatProductViewPriceFont: UIFont {
        return helveticaNeueBoldFont(size: 16)
    }
    
    static var chatProductViewNameColor: UIColor {
        return black
    }
    
    static var chatProductViewUserColor: UIColor {
        return gray153
    }
    
    static var chatProductViewPriceColor: UIColor {
        return black
    }
    
    static var chatCellAvatarBorderColor: UIColor {
        return gray213
    }
    
    static var chatSendButtonTintColor: UIColor {
        return red
    }
    
    
    // MARK: - Chat safety tips
    
    static var tipTextColor: UIColor {
        return gray75
    }
    
    static var tipTextFont: UIFont {
        return helveticaNeueMediumFont(size: 14)
    }

    
    // MARK: - LGTextField
    
    static var textFieldTintColor: UIColor {
        return red
    }
    
    // MARK: Button
    
    static var highlightedRedButtonColor: UIColor {
        return highlightedRed
    }
    
    static var disabledButtonAlpha: CGFloat {
        return disabledItemAlpha
    }
}

extension UIButton {

    /**
        Will set default corner radius and button background to the app primary color
    */
    func setPrimaryStyle() {
        guard buttonType == UIButtonType.Custom else {
            print("💣 => primaryStyle can only be applied to customStyle Buttons")
            return
        }
        setBackgroundImage(StyleHelper.primaryColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        setBackgroundImage(StyleHelper.primaryColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Highlighted)
        layer.cornerRadius = StyleHelper.buttonCornerRadius
    }

    func setSecondaryStyle() {
        guard buttonType == UIButtonType.System else {
            print("💣 => secondaryStyle can only be applied to systemStyle Buttons")
            return
        }
        
        layer.cornerRadius = StyleHelper.buttonCornerRadius
        layer.borderColor = StyleHelper.primaryColor.CGColor
        layer.borderWidth = 2
        setBackgroundImage(StyleHelper.primaryColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        setBackgroundImage(StyleHelper.white.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
    }
}
