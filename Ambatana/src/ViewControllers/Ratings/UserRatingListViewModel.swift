//
//  UserRatingListViewModel.swift
//  LetGo
//
//  Created by Dídac on 18/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol UserRatingListViewModelDelegate : class {
    func vmDidLoadUserRatings(ratings: [UserRating])
    func vmDidFailLoadingUserRatings()
    func showActionSheetForCellAtIndex(cancelAction: UIAction, actions: [UIAction])
}


class UserRatingListViewModel: BaseViewModel {

    // list data
    var ratings: [UserRating]
    var objectCount: Int {
        return ratings.count
    }

    var userIdRated: String

    var isMyRatingsList: Bool {
        return myUserRepository.myUser?.objectId == userIdRated && userIdRated != ""
    }

    var userRatingListRequester: UserRatingListRequester
    var myUserRepository: MyUserRepository

    weak var delegate: UserRatingListViewModelDelegate?


    // MARK: Lifecycle

    convenience init(userId: String?) {
        let requester = UserRatingListRequester(userId: userId ?? "")
        let myUserRepository = Core.myUserRepository
        self.init(userIdRated: userId, userRatingListRequester: requester, myUserRepository: myUserRepository)
    }

    required init(userIdRated: String?, userRatingListRequester: UserRatingListRequester, myUserRepository: MyUserRepository) {
        self.userRatingListRequester = userRatingListRequester
        self.myUserRepository = myUserRepository
        self.userIdRated = userIdRated ?? ""
        self.ratings = []
        super.init()
    }
    
    override func didBecomeActive(firstTime: Bool) {
        userRatingListRequester.delegate = self
        userRatingListRequester.retrieveFirstPage()
    }


    func ratingAtIndex(index: Int) -> UserRating? {
        guard index < objectCount else { return nil }
        return ratings[index]
    }

    func dataForCellAtIndexPath(indexPath: NSIndexPath) -> UserRatingCellData? {
        guard let rating = ratingAtIndex(indexPath.row) else { return nil }
        let avatarPlaceholder = LetgoAvatar.avatarWithID(rating.userFrom.objectId, name: rating.userFrom.name)
        let ratingDate = rating.updatedAt ?? rating.createdAt

        return UserRatingCellData(userName: rating.userFrom.name ?? "", userAvatar: rating.userFrom.avatar?.fileURL,
                                      userAvatarPlaceholder: avatarPlaceholder, ratingType: rating.type,
                                      ratingValue: rating.value, ratingDescription: rating.comment, ratingDate: ratingDate,
                                      isMyRating: isMyRatingsList)
    }
}

extension UserRatingListViewModel : UserRatingListRequesterDelegate {
    func requesterDidLoadUserRatings(ratings: [UserRating]) {
        self.ratings = ratings
        delegate?.vmDidLoadUserRatings(ratings)
    }

    func requesterDidFailLoadingUserRatings() {

    }
}

extension UserRatingListViewModel:  UserRatingCellDelegate {

    func actionButtonPressedForCellAtIndex(indexPath: NSIndexPath) {
        var actions: [UIAction] = []
        let userFrom = ratings[indexPath.row].userFrom

        // TODO: ⚠️➡️ set proper actions
        // https://ambatana.atlassian.net/browse/ABIOS-1419

        let reviewAction = UIAction(interface: .Text(LGLocalizedString.ratingListActionReviewUser), action: {
            print("REVIEW ACTION for user \(userFrom)")})

        let reportAction = UIAction(interface: .Text(LGLocalizedString.ratingListActionReportReview), action: {
            print("REPORT ACTION for user \(userFrom)")
            })

        actions = [reviewAction, reportAction]

        let cancelAction = UIAction(interface: .Text(LGLocalizedString.commonCancel), action: {
            print("CANCEL ACTION")
        })

        delegate?.showActionSheetForCellAtIndex(cancelAction, actions: actions)
    }
}