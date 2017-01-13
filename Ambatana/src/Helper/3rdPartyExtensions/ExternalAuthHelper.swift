//
//  ExternalAuthHelper.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

typealias ExternalAuthLoginCompletion = ((ExternalServiceAuthResult) -> ())

protocol ExternalAuthHelper {
    func login(_ authCompletion: (() -> Void)?, loginCompletion: ExternalAuthLoginCompletion?)
}
