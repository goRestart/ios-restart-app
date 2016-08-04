//
//  UserRatingListRequester.swift
//  LetGo
//
//  Created by Dídac on 18/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol UserRatingListRequesterDelegate: class {
    func requesterIsLoadingUserRatings(isLoading: Bool, firstPage: Bool)
    func requesterDidLoadUserRatings(ratings: [UserRating])
    func requesterDidFailLoadingUserRatings(firstPage: Bool)
}

class UserRatingListRequester {

    // Paginable
    var nextPage: Int = 0
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int = 0

    var userId: String
    var userRatingRepository: UserRatingRepository

    weak var delegate: UserRatingListRequesterDelegate?


    // MARK: Lifecycle

    convenience init(userId: String) {
        self.init(userRatingRepository: Core.userRatingRepository, userId: userId)
    }

    init(userRatingRepository: UserRatingRepository, userId: String) {
        self.userRatingRepository = userRatingRepository
        self.userId = userId
    }


    // MARK: public methods

    func reportRating(rating: UserRating, completion: UserRatingEmptyCompletion?) {
        userRatingRepository.reportRating(rating, completion: completion)
    }
}


// MARK: Paginable

extension UserRatingListRequester: Paginable {
    func retrievePage(page: Int) {
        isLoading = true
        delegate?.requesterIsLoadingUserRatings(isLoading, firstPage: nextPage == 0)
        userRatingRepository.index(userId, offset: objectCount, limit: resultsPerPage) { [weak self] result in
            if let value = result.value {
                self?.delegate?.requesterDidLoadUserRatings(value)
                self?.objectCount += value.count
            } else if let _ = result.error {
                self?.delegate?.requesterDidFailLoadingUserRatings(self?.nextPage == 0)
            }
            self?.isLoading = false
            self?.delegate?.requesterIsLoadingUserRatings(self?.isLoading ?? false, firstPage: self?.nextPage == 0)
        }
    }
}
