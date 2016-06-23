//
//  UIFont+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 26/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UIFont {

    // Titles
    static var bigHeadlineFont: UIFont { return systemRegularFont(size: 30) }
    static var mediumHeadlineFont: UIFont { return systemSemiBoldFont(size: 19) }
    static var pageTitleFont: UIFont { return systemSemiBoldFont(size: 17) }

    // Bar Buttons
    // TODO: improve those 2 names (when is used one ant the other? active/inactive?? )
    static var boldBarButtonFont: UIFont { return systemSemiBoldFont(size: 17) }
    static var regularButtonFont: UIFont { return systemRegularFont(size: 17) }

    // Body
    static var bigBodyFont: UIFont { return systemRegularFont(size: 17) }
    static var mediumBodyFont: UIFont { return systemRegularFont(size: 15) }
    static var smallBodyFont: UIFont { return systemRegularFont(size: 13) }
    static var subtitleFont: UIFont { return systemRegularFont(size: 11) }

    // Tabs
    static var inactiveTabFont: UIFont { return systemRegularFont(size: 15) }
    static var activeTabFont: UIFont { return systemSemiBoldFont(size: 15) }

    // Section Title
    static var sectionTitleFont: UIFont { return systemRegularFont(size: 13) }

    // Button
    static var bigButtonFont: UIFont { return systemSemiBoldFont(size: 19) }
    static var mediumButtonFont: UIFont { return systemMediumFont(size: 17) }
    static var smallButtonFont: UIFont { return systemMediumFont(size: 15) }

    static var bodyFont: UIFont { return systemFont(size: 17) }
    

    // MARK: Private methods
    
    static func systemFont(size size: Int) -> UIFont {
        return systemFontOfSize(CGFloat(size))
    }
    
    static func systemMediumFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return systemFontOfSize(CGFloat(size), weight: UIFontWeightMedium)
        } else {
            return UIFont(name: "HelveticaNeue-Medium", size: CGFloat(size))!
        }
    }
    
    static func systemLightFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return systemFontOfSize(CGFloat(size), weight: UIFontWeightLight)
        } else {
            return UIFont(name: "HelveticaNeue-Light", size: CGFloat(size))!
        }
    }
    
    static func systemRegularFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return systemFontOfSize(CGFloat(size), weight: UIFontWeightRegular)
        } else {
            return UIFont(name: "HelveticaNeue", size: CGFloat(size))!
        }
    }
    
    static func systemSemiBoldFont(size size: Int) -> UIFont {
        if #available(iOS 9.0, *) {
            return systemFontOfSize(CGFloat(size), weight: UIFontWeightSemibold)
        } else {
            return UIFont(name: "HelveticaNeue-Bold", size: CGFloat(size))!
        }
    }
    
    static func systemBoldFont(size size: Int) -> UIFont {
        return boldSystemFontOfSize(CGFloat(size))
    }
    
    static func systemItalicFont(size size: Int) -> UIFont {
        return italicSystemFontOfSize(CGFloat(size))
    }
}
