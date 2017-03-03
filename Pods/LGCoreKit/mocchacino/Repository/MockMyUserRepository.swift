import Result
import RxSwift

open class MockMyUserRepository: MyUserRepository {
    public var result: MyUserResult
    public var myUserVar: Variable<MyUser?>

    
    // MARK: - Lifecycle

    public init() {
        self.result = MyUserResult(value: MockMyUser.makeMock())
        self.myUserVar = Variable<MyUser?>(nil)
    }


    // MARK: - MyUserRepository

    public var myUser: MyUser? {
        return myUserVar.value
    }
    public var rx_myUser: Observable<MyUser?> {
        return myUserVar.asObservable()
    }

    public func updateName(_ name: String, completion: MyUserCompletion?) {
        delay(result: result, completion: completion)
    }

    public func updatePassword(_ password: String, completion: MyUserCompletion?) {
        delay(result: result, completion: completion)
    }

    public func resetPassword(_ password: String, token: String, completion: MyUserCompletion?) {
        delay(result: result, completion: completion)
    }

    public func updateEmail(_ email: String, completion: MyUserCompletion?) {
        delay(result: result, completion: completion)
    }

    public func updateAvatar(_ avatar: Data, progressBlock: ((Int) -> ())?, completion: MyUserCompletion?) {
        delay(result: result, completion: completion)
    }

    public func linkAccount(_ email: String, completion: MyUserCompletion?) {
        delay(result: result, completion: completion)
    }

    public func linkAccountFacebook(_ token: String, completion: MyUserCompletion?) {
        delay(result: result, completion: completion)
    }

    public func linkAccountGoogle(_ token: String, completion: MyUserCompletion?) {
        delay(result: result, completion: completion)
    }

    public func refresh(_ completion: MyUserCompletion?) {
        delay(result: result, completion: completion)
    }
}
