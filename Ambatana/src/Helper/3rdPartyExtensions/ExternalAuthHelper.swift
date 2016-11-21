//
//  ExternalAuthHelper.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

typealias ExternalAuthLoginCompletion = (ExternalServiceAuthResult -> ())

protocol ExternalAuthHelper {
    func login(authCompletion: (() -> Void)?, loginCompletion: ExternalAuthLoginCompletion?)
}
