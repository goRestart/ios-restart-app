
final class MockExternalAuthHelper: ExternalAuthHelper {
    var loginResult: ExternalServiceAuthResult!

    init(result: ExternalServiceAuthResult) {
        self.loginResult = result
    }

    func login(_ authCompletion: (() -> Void)?, loginCompletion: ExternalAuthLoginCompletion?) {
        authCompletion?()
        loginCompletion?(loginResult)
    }
}
