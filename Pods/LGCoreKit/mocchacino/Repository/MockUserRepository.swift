import Result
import RxSwift

open class MockUserRepository: InternalUserRepository {

    public var eventsPublishSubject = PublishSubject<UserRepositoryEvent>()
    public var indexResult: UsersResult!
    public var userResult: UserResult!
    public var userUserRelationResult: UserUserRelationResult!
    public var emptyResult: UserVoidResult!


    // MARK: - Lifecycle

    required public init() {
        
    }


    // MARK: - UserRepository {

    public func show(_ userId: String, completion: UserCompletion?) {
        delay(result: userResult, completion: completion)
    }

    public func retrieveUserToUserRelation(_ relatedUserId: String, completion: UserUserRelationCompletion?) {
        delay(result: userUserRelationResult, completion: completion)
    }

    public func indexBlocked(_ completion: UsersCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func internalBlockUserWithId(_ userId: String, completion: UserVoidCompletion?) {
        delay(result: emptyResult, completion: completion)
    }

    public func internalUnblockUserWithId(_ userId: String, completion: UserVoidCompletion?) {
        delay(result: emptyResult, completion: completion)
    }

    public func saveReport(_ reportedUser: User, params: ReportUserParams, completion: UserCompletion?) {
        delay(result: userResult, completion: completion)
    }

    public func saveReport(_ reportedUserId: String, params: ReportUserParams, completion: UserVoidCompletion?) {
        delay(result: emptyResult, completion: completion)
    }
}
