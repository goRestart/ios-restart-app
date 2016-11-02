//
//  NSLocale+LG.swift
//  LetGo
//
//  Created by Dídac on 02/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension NSLocale {
    var systemCountryCode: String {
        if #available(iOS 10.0, *) {
            return self.countryCode ?? ""
        } else {
            return self.objectForKey(NSLocaleCountryCode) as? String ?? ""
        }
    }
}
