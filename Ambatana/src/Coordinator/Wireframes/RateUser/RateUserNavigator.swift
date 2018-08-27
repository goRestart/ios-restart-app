typealias UserRatingValue = Int
extension UserRatingValue {
    var shouldShowAppRating: Bool { return self == 5 }
}
protocol RateUserNavigator {
    func rateUserCancel()
    func rateUserSkip()
    func rateUserFinish(withRating rating: UserRatingValue)
}
