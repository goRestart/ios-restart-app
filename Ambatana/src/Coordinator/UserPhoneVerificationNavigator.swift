//
//  UserPhoneVerificationNavigator.swift
//  LetGo
//
//  Created by Sergi Gracia on 05/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

protocol UserPhoneVerificationNavigator: class {
    func openCountrySelector(withDelegate: UserPhoneVerificationCountryPickerDelegate)
    func closeCountrySelector()
    func openCodeInput(sentTo phoneNumber: String, with callingCode: String)
    func closePhoneVerificaction()
}
