import Result
import RxSwift

open class MockMyUserRepository: MyUserRepository {
    public var myUserVar = Variable<MyUser?>(nil)

    public var result: MyUserResult!
    public var resultVoid: MyUserVoidResult!
    public var resultActions: MyUserReputationActionsResult!

    
    // MARK: - Lifecycle

    required public init() {}


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

    public func updateBiography(_ biography: String, completion: MyUserCompletion?) {
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

    public func retrieveUserReputationActions(_ completion: MyUserReputationActionsCompletion?) {
        delay(result: resultActions, completion: completion)
    }

    public func requestSMSCode(prefix: String, phone: String, completion: MyUserVoidCompletion?) {
        delay(result: resultVoid, completion: completion)
    }

    public func validateSMSCode(_ code: String, completion: MyUserVoidCompletion?) {
        delay(result: resultVoid, completion: completion)
    }
    
    public func notifyReferral(inviterId: String, completion: @escaping (Result<Void, RepositoryError>) -> Void) {
        delay(result: resultVoid, completion: completion)
    }
}
