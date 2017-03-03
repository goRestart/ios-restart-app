import CoreLocation
import Result
import RxSwift

open class MockSessionManager: SessionManager {
    public var sessionEventsPublishSubject: PublishSubject<SessionEvent>
    public var logInResult: SessionMyUserResult
    public var signUpResult: SessionMyUserResult
    public var recoverPasswordResult: SessionEmptyResult


    // MARK: - Lifecycle

    public init() {
        self.sessionEventsPublishSubject = PublishSubject<SessionEvent>()
        self.logInResult = SessionMyUserResult(value: MockMyUser.makeMock())
        self.signUpResult = SessionMyUserResult(value: MockMyUser.makeMock())
        self.recoverPasswordResult = SessionEmptyResult(value: Void())
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
                       completion: SessionMyUserCompletion?) {
        delay(result: signUpResult, completion: completion)
    }

    public func signUp(_ email: String,
                       password: String,
                       name: String,
                       newsletter: Bool?,
                       recaptchaToken: String,
                       completion: SessionMyUserCompletion?) {
        delay(result: signUpResult, completion: completion)
    }

    public func login(_ email: String,
                      password: String,
                      completion: SessionMyUserCompletion?) {
        delay(result: logInResult, completion: completion)
    }

    public func loginFacebook(_ token: String,
                              completion: SessionMyUserCompletion?) {
        delay(result: logInResult, completion: completion)
    }

    public func loginGoogle(_ token: String,
                            completion: SessionMyUserCompletion?) {
        delay(result: logInResult, completion: completion)
    }

    public func recoverPassword(_ email: String,
                                completion: SessionEmptyCompletion?) {
        delay(result: recoverPasswordResult, completion: completion)
    }

    public func logout() {
    }

    public func startChat() {
    }
}
