import Result
import RxSwift

open class MockUserRepository: UserRepository {
    public var indexResult: UsersResult
    public var userResult: UserResult
    public var userUserRelationResult: UserUserRelationResult
    public var emptyResult: UserVoidResult


    // MARK: - Lifecycle

    public init() {
        self.indexResult = UsersResult(value: MockUser.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        self.userResult = UserResult(value: MockUser.makeMock())
        self.userUserRelationResult = UserUserRelationResult(value: MockUserUserRelation.makeMock())
        self.emptyResult = UserVoidResult(value: Void())
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

    public func blockUserWithId(_ userId: String, completion: UserVoidCompletion?) {
        delay(result: emptyResult, completion: completion)
    }

    public func unblockUserWithId(_ userId: String, completion: UserVoidCompletion?) {
        delay(result: emptyResult, completion: completion)
    }

    public func unblockUsersWithIds(_ userIds: [String], completion: UserVoidCompletion?) {
        delay(result: emptyResult, completion: completion)
    }

    public func saveReport(_ reportedUser: User, params: ReportUserParams, completion: UserCompletion?) {
        delay(result: userResult, completion: completion)
    }

    public func saveReport(_ reportedUserId: String, params: ReportUserParams, completion: UserVoidCompletion?) {
        delay(result: emptyResult, completion: completion)
    }
}
