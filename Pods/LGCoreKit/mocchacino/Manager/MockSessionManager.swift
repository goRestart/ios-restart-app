import CoreLocation
import Result
import RxSwift

open class MockSessionManager: SessionManager {
    public var sessionEventsPublishSubject: PublishSubject<SessionEvent>
    public var logInResult: LoginResult
    public var signUpResult: SignupResult
    public var recoverPasswordResult: RecoverPasswordResult


    // MARK: - Lifecycle

    public init() {
        self.sessionEventsPublishSubject = PublishSubject<SessionEvent>()
        self.logInResult = LoginResult(value: MockMyUser.makeMock())
        self.signUpResult = SignupResult(value: MockMyUser.makeMock())
        self.recoverPasswordResult = RecoverPasswordResult(value: Void())
        self.loggedIn = false
    }


    // MARK: - SessionManager

    public var sessionEvents: Observable<SessionEvent> {
        return sessionEventsPublishSubject.asObservable()
    }

    public var loggedIn: Bool

    public func signUp(_ email: String,
                       password: String,
                       name: String,
                       newsletter: Bool?,
                       completion: SignupCompletion?) {
        delay(result: signUpResult, completion: completion)
    }

    public func signUp(_ email: String,
                       password: String,
                       name: String,
                       newsletter: Bool?,
                       recaptchaToken: String,
                       completion: SignupCompletion?) {
        delay(result: signUpResult, completion: completion)
    }

    public func login(_ email: String,
                      password: String,
                      completion: LoginCompletion?) {
        delay(result: logInResult, completion: completion)
    }

    public func loginFacebook(_ token: String,
                              completion: LoginCompletion?) {
        delay(result: logInResult, completion: completion)
    }

    public func loginGoogle(_ token: String,
                            completion: LoginCompletion?) {
        delay(result: logInResult, completion: completion)
    }

    public func recoverPassword(_ email: String,
                                completion: RecoverPasswordCompletion?) {
        delay(result: recoverPasswordResult, completion: completion)
    }

    public func logout() {
    }

    public func startChat() {
    }
}
