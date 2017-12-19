        
extension MockUserRatingRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockUserRatingRepository = self.init()
        mockUserRatingRepository.indexResult = UserRatingsResult(value: MockUserRating.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockUserRatingRepository.ratingResult = UserRatingResult(value: MockUserRating.makeMock())
        return mockUserRatingRepository
    }
}
