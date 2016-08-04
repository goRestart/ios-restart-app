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
    func vmIsLoadingUserRatingsRequest(isLoading: Bool, firstPage: Bool)
    func vmDidLoadUserRatings(ratings: [UserRating])
    func vmDidFailLoadingUserRatings(firstPage: Bool)
    func vmShowUserRating(source: RateUserSource, data: RateUserData)
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


    // MARK: Lifecycle

    convenience init(userId: String) {
        let requester = UserRatingListRequester(userId: userId)
        let myUserRepository = Core.myUserRepository
        self.init(userIdRated: userId, userRatingListRequester: requester, myUserRepository: myUserRepository)
    }

    required init(userIdRated: String, userRatingListRequester: UserRatingListRequester, myUserRepository: MyUserRepository) {
        self.userRatingListRequester = userRatingListRequester
        self.myUserRepository = myUserRepository
        self.userIdRated = userIdRated
        self.ratings = []
        super.init()
    }
    
    override func didBecomeActive(firstTime: Bool) {
        if firstTime {
            userRatingListRequester.delegate = self
            userRatingListRequester.retrieveFirstPage()
        }
    }


    // MARK: public methods

    func dataForCellAtIndexPath(indexPath: NSIndexPath) -> UserRatingCellData? {
        guard let rating = ratingAtIndex(indexPath.row) else { return nil }
        let avatarPlaceholder = LetgoAvatar.avatarWithID(rating.userFrom.objectId, name: rating.userFrom.name)
        let ratingDate = rating.updatedAt ?? rating.createdAt

        return UserRatingCellData(userName: rating.userFrom.name ?? "", userAvatar: rating.userFrom.avatar?.fileURL,
                                      userAvatarPlaceholder: avatarPlaceholder, ratingType: rating.type,
                                      ratingValue: rating.value, ratingDescription: rating.comment, ratingDate: ratingDate,
                                      isMyRating: isMyRatingsList)
    }


    // MARK: private methods

    private func ratingAtIndex(index: Int) -> UserRating? {
        guard index < objectCount else { return nil }
        return ratings[index]
    }
}

extension UserRatingListViewModel : UserRatingListRequesterDelegate {

    func requesterIsLoadingUserRatings(isLoading: Bool, firstPage: Bool) {
        delegate?.vmIsLoadingUserRatingsRequest(isLoading, firstPage: firstPage)
    }

    func requesterDidLoadUserRatings(ratings: [UserRating]) {
        self.ratings = ratings
        delegate?.vmDidLoadUserRatings(ratings)
    }

    func requesterDidFailLoadingUserRatings(firstPage: Bool) {
        delegate?.vmDidFailLoadingUserRatings(firstPage)
    }
}

extension UserRatingListViewModel:  UserRatingCellDelegate {
    
    func actionButtonPressedForCellAtIndex(indexPath: NSIndexPath) {
        guard let rating = ratingAtIndex(indexPath.row) else { return }
        let userFrom = rating.userFrom

        var actions: [UIAction] = []

        let reviewAction = UIAction(interface: .Text(LGLocalizedString.ratingListActionReviewUser), action: { [weak self] in
            guard let userData = RateUserData(user: userFrom) else { return }
            self?.delegate?.vmShowUserRating(.UserRatingList, data: userData)
        })

        actions = [reviewAction]

        if rating.status == .Published {
            let reportAction = UIAction(interface: .Text(LGLocalizedString.ratingListActionReportReview), action: { [weak self] in
                self?.userRatingListRequester.reportRating(rating, completion: { result in
                    if let _ = result.value {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.ratingListActionReportReviewSuccessMessage,
                            completion: nil)
                    } else if let _ = result.error {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.ratingListActionReportReviewErrorMessage,
                            completion: nil)
                    }
                })
            })
            actions.append(reportAction)
        }

        let cancelAction = UIAction(interface: .Text(LGLocalizedString.commonCancel), action: {})
        delegate?.vmShowActionSheet(cancelAction, actions: actions)
    }

    private func rateBackRatingType(receivedRating: UserRatingType) -> UserRatingType {
        switch receivedRating {
        case .Conversation:
            return .Conversation
        case let .Seller(productId):
            return .Buyer(productId: productId)
        case let .Buyer(productId):
            return .Seller(productId: productId)
        }
    }
}
