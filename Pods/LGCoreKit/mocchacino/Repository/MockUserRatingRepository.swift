import Result
import RxSwift

open class MockUserRatingRepository: UserRatingRepository {
    public var indexResult: UserRatingsResult
    public var ratingResult: UserRatingResult


    // MARK: - Lifecycle

    public init() {
        self.indexResult = UserRatingsResult(value: MockUserRating.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        self.ratingResult = UserRatingResult(value: MockUserRating.makeMock())
    }


    // MARK: - UserRatingRepository {

    public func index(_ userId: String,
                      offset: Int,
                      limit: Int,
                      completion: UserRatingsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func show(_ ratingId: String,
                     completion: UserRatingCompletion?) {
        delay(result: ratingResult, completion: completion)
    }

    public func show(_ userId: String,
                     type: UserRatingType,
                     completion: UserRatingCompletion?) {
        delay(result: ratingResult, completion: completion)
    }

    public func createRating(_ userId: String,
                             value: Int,
                             comment: String?,
                             type: UserRatingType,
                             completion: UserRatingCompletion?) {
        delay(result: ratingResult, completion: completion)
    }

    public func updateRating(_ rating: UserRating,
                             value: Int?,
                             comment: String?,
                             completion: UserRatingCompletion?) {
        delay(result: ratingResult, completion: completion)
    }

    public func reportRating(_ rating: UserRating,
                             completion: UserRatingCompletion?) {
        delay(result: ratingResult, completion: completion)
    }
}
