//
//  UserRatingListViewModel.swift
//  LetGo
//
//  Created by Dídac on 18/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol UserRatingListViewModelDelegate : BaseViewModelDelegate {
    func vmIsLoadingUserRatingsRequest(_ isLoading: Bool, firstPage: Bool)
    func vmDidLoadUserRatings(_ ratings: [UserRating])
    func vmDidFailLoadingUserRatings(_ firstPage: Bool)
    func vmShowUserRating(_ source: RateUserSource, data: RateUserData)
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

    weak var delegate: UserRatingListViewModelDelegate?
    weak var tabNavigator: TabNavigator?


    // MARK: Lifecycle

    convenience init(userId: String, tabNavigator: TabNavigator?) {
        let requester = UserRatingListRequester(userId: userId)
        let myUserRepository = Core.myUserRepository
        self.init(userIdRated: userId, userRatingListRequester: requester, myUserRepository: myUserRepository,
                  tabNavigator: tabNavigator)
    }

    required init(userIdRated: String, userRatingListRequester: UserRatingListRequester,
                  myUserRepository: MyUserRepository, tabNavigator: TabNavigator?) {
        self.userRatingListRequester = userRatingListRequester
        self.myUserRepository = myUserRepository
        self.tabNavigator = tabNavigator
        self.userIdRated = userIdRated
        self.ratings = []
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
        self.ratings = ratings
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

        let reviewAction = UIAction(interface: .text(LGLocalizedString.ratingListActionReviewUser), action: { [weak self] in
            guard let userData = RateUserData(user: userFrom) else { return }
            self?.delegate?.vmShowUserRating(.userRatingList, data: userData)
        }, accessibilityId: .ratingListCellReview)
        actions.append(reviewAction)

        let reportAction = UIAction(interface: .text(LGLocalizedString.ratingListActionReportReview), action: { [weak self] in
            self?.delegate?.vmShowLoading(nil)
            self?.userRatingListRequester.reportRating(rating, completion: { result in
                if let ratingUpdated = result.value {
                    self?.replaceRating(ratingUpdated)
                    self?.delegate?.vmRefresh()
                    self?.delegate?.vmHideLoading(LGLocalizedString.ratingListActionReportReviewSuccessMessage,
                        afterMessageCompletion: nil)
                } else if let _ = result.error {
                    self?.delegate?.vmHideLoading(LGLocalizedString.ratingListActionReportReviewErrorMessage,
                        afterMessageCompletion: nil)
                }
            })
        }, accessibilityId: .ratingListCellReport)
        actions.append(reportAction)

        let cancelAction = UIAction(interface: .text(LGLocalizedString.commonCancel), action: {})
        delegate?.vmShowActionSheet(cancelAction, actions: actions)
    }

    private func rateBackRatingType(_ receivedRating: UserRatingType) -> UserRatingType {
        switch receivedRating {
        case .conversation:
            return .conversation
        case let .seller(productId):
            return .buyer(productId: productId)
        case let .buyer(productId):
            return .seller(productId: productId)
        }
    }
}

