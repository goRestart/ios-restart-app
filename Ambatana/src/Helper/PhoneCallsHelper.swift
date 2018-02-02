//
//  PhoneCallsHelper.swift
//  LetGo
//
//  Created by Dídac on 23/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class PhoneCallsHelper {
    static var deviceCanCall: Bool {
        guard let callUrl = URL(string: "tel:") else { return false }
        return UIApplication.shared.canOpenURL(callUrl)
    }

    static func call(phoneNumber: String) {
        guard let phoneUrl = URL(string: "tel:\(phoneNumber)") else { return }
        UIApplication.shared.openURL(phoneUrl)
    }
}
