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
    func requesterIsLoadingUserRatings(_ isLoading: Bool, firstPage: Bool)
    func requesterDidLoadUserRatings(_ ratings: [UserRating], firstPage: Bool)
    func requesterDidFailLoadingUserRatings(_ firstPage: Bool)
}

class UserRatingListRequester {

    // Paginable
    let firstPage: Int = 0
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

    func reportRating(_ rating: UserRating, completion: UserRatingCompletion?) {
        userRatingRepository.reportRating(rating, completion: completion)
    }
}


// MARK: Paginable

extension UserRatingListRequester: Paginable {
    func retrievePage(_ page: Int) {
        isLoading = true
        let isFirstPage = page == firstPage
        if isFirstPage {
            objectCount = 0
        }
        delegate?.requesterIsLoadingUserRatings(isLoading, firstPage: isFirstPage)
        userRatingRepository.index(userId, offset: objectCount, limit: resultsPerPage) { [weak self] result in
            if let value = result.value {
                self?.nextPage += 1
                self?.delegate?.requesterDidLoadUserRatings(value, firstPage: isFirstPage)
                self?.objectCount += value.count
            } else if let _ = result.error {
                self?.delegate?.requesterDidFailLoadingUserRatings(isFirstPage)
            }
            self?.isLoading = false
            self?.delegate?.requesterIsLoadingUserRatings(self?.isLoading ?? false, firstPage: isFirstPage)
        }
    }
}
