//
//  UIFont+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 26/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UIFont {
    
    static var bigButtonFont: UIFont { return systemSemiBoldFont(size: 19) }
    static var defaultButtonFont: UIFont { return systemSemiBoldFont(size: 17) }
    static var smallButtonFont: UIFont { return systemSemiBoldFont(size: 15) }

    
    // MARK: Private methods
    
    private static func systemFont(size size: Int) -> UIFont {
        return systemFontOfSize(CGFloat(size))
    }
    
    private static func systemMediumFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return systemFontOfSize(CGFloat(size), weight: UIFontWeightMedium)
        } else {
            return UIFont(name: "HelveticaNeue-Medium", size: CGFloat(size))!
        }
    }
    
    private static func systemLightFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return systemFontOfSize(CGFloat(size), weight: UIFontWeightLight)
        } else {
            return UIFont(name: "HelveticaNeue-Light", size: CGFloat(size))!
        }
    }
    
    private static func systemRegularFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return systemFontOfSize(CGFloat(size), weight: UIFontWeightRegular)
        } else {
            return UIFont(name: "HelveticaNeue", size: CGFloat(size))!
        }
    }
    
    private static func systemSemiBoldFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return systemFontOfSize(CGFloat(size), weight: UIFontWeightSemibold)
        } else {
            return UIFont(name: "HelveticaNeue-Bold", size: CGFloat(size))!
        }
    }
    
    private static func systemBoldFont(size size: Int) -> UIFont {
        return boldSystemFontOfSize(CGFloat(size))
    }
    
    private static func systemItalicFont(size size: Int) -> UIFont {
        return italicSystemFontOfSize(CGFloat(size))
    }
}
