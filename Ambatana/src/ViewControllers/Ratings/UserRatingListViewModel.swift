import Foundation
import LGCoreKit
import LGComponents

protocol UserRatingListViewModelDelegate : BaseViewModelDelegate {
    func vmIsLoadingUserRatingsRequest(_ isLoading: Bool, firstPage: Bool)
    func vmDidLoadUserRatings(_ ratings: [UserRating])
    func vmDidFailLoadingUserRatings(_ firstPage: Bool)
    func vmRefresh()
}


class UserRatingListViewModel: BaseViewModel {

    // list data
    var ratings: [UserRating]
    var objectCount: Int {
        return ratings.count
    }

    var userIdRated: String

    var isMyRatingsList: Bool {
        return myUserRepository.myUser?.objectId == userIdRated
    }

    var userRatingListRequester: UserRatingListRequester
    var myUserRepository: MyUserRepository
    let tracker: Tracker

    weak var delegate: UserRatingListViewModelDelegate?
    weak var tabNavigator: TabNavigator?


    // MARK: Lifecycle

    convenience init(userId: String,
                     tabNavigator: TabNavigator?) {
        let requester = UserRatingListRequester(userId: userId)
        let myUserRepository = Core.myUserRepository
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.init(userIdRated: userId,
                  userRatingListRequester: requester,
                  myUserRepository: myUserRepository,
                  tabNavigator: tabNavigator,
                  tracker: tracker)
    }

    required init(userIdRated: String,
                  userRatingListRequester: UserRatingListRequester,
                  myUserRepository: MyUserRepository,
                  tabNavigator: TabNavigator?,
                  tracker: Tracker) {
        self.userRatingListRequester = userRatingListRequester
        self.myUserRepository = myUserRepository
        self.tabNavigator = tabNavigator
        self.userIdRated = userIdRated
        self.ratings = []
        self.tracker = tracker

        super.init()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            userRatingListRequester.delegate = self
            userRatingListRequester.retrieveFirstPage()
        }
    }


    // MARK: public methods

    func dataForCellAtIndexPath(_ indexPath: IndexPath) -> UserRatingCellData? {
        guard let rating = ratingAtIndex(indexPath.row) else { return nil }
        let avatarPlaceholder = LetgoAvatar.avatarWithID(rating.userFrom.objectId, name: rating.userFrom.name)
        let ratingDate = rating.createdAt > rating.updatedAt ? rating.createdAt : rating.updatedAt

        return UserRatingCellData(userName: rating.userFrom.name ?? "", userAvatar: rating.userFrom.avatar?.fileURL,
                                      userAvatarPlaceholder: avatarPlaceholder, ratingType: rating.type,
                                      ratingValue: rating.value, ratingDescription: rating.comment, ratingDate: ratingDate,
                                      isMyRating: isMyRatingsList, pendingReview: rating.status == .pendingReview)
    }

    func setCurrentIndex(_ index: Int) {
        userRatingListRequester.setCurrentIndex(index)
    }

    // MARK: private methods

    fileprivate func ratingAtIndex(_ index: Int) -> UserRating? {
        guard index < objectCount else { return nil }
        return ratings[index]
    }
    
    fileprivate func replaceRating(_ rating: UserRating) {
        guard let index = ratings.index (where: { $0.objectId == rating.objectId }) else { return }
        ratings[index] = rating
    }
}

extension UserRatingListViewModel : UserRatingListRequesterDelegate {

    func requesterIsLoadingUserRatings(_ isLoading: Bool, firstPage: Bool) {
        delegate?.vmIsLoadingUserRatingsRequest(isLoading, firstPage: firstPage)
    }

    func requesterDidLoadUserRatings(_ ratings: [UserRating]) {
        self.ratings.append(contentsOf: ratings)
        delegate?.vmDidLoadUserRatings(ratings)
    }

    func requesterDidFailLoadingUserRatings(_ firstPage: Bool) {
        delegate?.vmDidFailLoadingUserRatings(firstPage)
    }
}

extension UserRatingListViewModel:  UserRatingCellDelegate {
    
    func actionButtonPressedForCellAtIndex(_ indexPath: IndexPath) {
        guard let rating = ratingAtIndex(indexPath.row) else { return }
        guard rating.status == .published else { return }
        let userFrom = rating.userFrom
        
        var actions: [UIAction] = []

        let reviewAction = UIAction(interface: .text(R.Strings.ratingListActionReviewUser), action: { [weak self] in
            guard let userData = RateUserData(user: userFrom, listingId: rating.listingId, ratingType: rating.type.rateBackType) else { return }
            self?.tabNavigator?.openUserRating(.userRatingList, data: userData)
        }, accessibility: AccessibilityId.ratingListCellReview)
        actions.append(reviewAction)

        let reportAction = UIAction(interface: .text(R.Strings.ratingListActionReportReview), action: { [weak self] in
            self?.delegate?.vmShowLoading(nil)
            self?.userRatingListRequester.reportRating(rating, completion: { result in
                if let ratingUpdated = result.value {
                    self?.replaceRating(ratingUpdated)
                    self?.delegate?.vmRefresh()
                    self?.delegate?.vmHideLoading(R.Strings.ratingListActionReportReviewSuccessMessage,
                                                  afterMessageCompletion: nil)
                    self?.trackReviewReported(userFromId: rating.userFrom.objectId , ratingStars: rating.value)
                } else if let _ = result.error {
                    self?.delegate?.vmHideLoading(R.Strings.ratingListActionReportReviewErrorMessage,
                                                  afterMessageCompletion: nil)
                }
            })
        }, accessibility: AccessibilityId.ratingListCellReport)
        actions.append(reportAction)

        let cancelAction = UIAction(interface: .text(R.Strings.commonCancel), action: {})
        delegate?.vmShowActionSheet(cancelAction, actions: actions)
    }
}


// MARK - Tracking

extension UserRatingListViewModel {
    func trackReviewReported(userFromId: String?, ratingStars: Int) {
        let trackerEvent = TrackerEvent.userRatingReport(userFromId: userFromId, ratingStars: ratingStars)
        tracker.trackEvent(trackerEvent)
    }
}

