//
//  CustomUtils.swift
//  Ambatana
//
//  Created by Nacho on 06/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

func iOSVersionAtLeast(version: String) -> Bool {
    switch UIDevice.currentDevice().systemVersion.compare(version, options: NSStringCompareOptions.NumericSearch) {
    case .OrderedSame, .OrderedDescending:
        return true
    case .OrderedAscending:
        return false
    }
}

extension String {
    func isEmail() -> Bool {
        let regex = NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]+$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, countElements(self))) != nil
    }
}

func ambatanaWebLinkForObjectId(objectId: String) -> String {
    return "http://www.ambatana.com/product/\(objectId)"
}

func ambatanaTextForSharingBody(productName: String, andObjectId objectId: String) -> String {
    return translate("have_a_look") + productName + "\n" + ambatanaWebLinkForObjectId(objectId)
}

func translate(text: String) -> String {
    return NSLocalizedString(text, comment: "")
}

func translateWithFormat(text: String, parameters: [CVarArgType]) -> String {
    return String(format: NSLocalizedString(text, comment: ""), arguments: parameters)
}