//
//  MockExternalAuthHelper.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode

class MockExternalAuthHelper: ExternalAuthHelper {
    var loginResult: ExternalServiceAuthResult!

    init(result: ExternalServiceAuthResult) {
        self.loginResult = result
    }

    func login(_ authCompletion: (() -> Void)?, loginCompletion: ExternalAuthLoginCompletion?) {
        authCompletion?()
        loginCompletion?(loginResult)
    }
}
