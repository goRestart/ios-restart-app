//
//  UserRatingRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 14/07/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias UserRatingsResult = Result<[UserRating], RepositoryError>
public typealias UserRatingsCompletion = (UserRatingsResult) -> Void

public typealias UserRatingResult = Result<UserRating, RepositoryError>
public typealias UserRatingCompletion = (UserRatingResult) -> Void


public protocol UserRatingRepository {

    /**
     Retrieves all ratings the given user has received

     - parameter userId: id of the user to retrieve ratings
     - parameter offset: Pagination offset
     - parameter limit: Number of items in each page
     - parameter completion: The completion closure
     */
    func index(_ userId: String, offset: Int, limit: Int, completion: UserRatingsCompletion?)

    /**
     Retrieves the rating the logged user has made to the given user

     - parameter ratingId: id of the rating to retrieve
     - parameter completion: The completion closure
     */
    func show(_ ratingId: String, completion: UserRatingCompletion?)

    /**
     Retrieves the rating the logged user has made to the given user
     
     - parameter userId: id of the user to retrieve rating
     - parameter listingId: id of the listing involved in the transaction
     - parameter type: Rating type
     - parameter completion: The completion closure
     */
    func show(_ userId: String, listingId: String?, type: UserRatingType, completion: UserRatingCompletion?)

    /**
     Adds a new rating to the given user

     - parameter userId:     user to rate
     - parameter value:      rating stars value
     - parameter comment:    rating comment
     - parameter type:       rating type (Conversation, Seller(listingId), Buyer(listingId))
     - parameter completion: The completion closure
     */
    func createRating(_ userId: String, value: Int, comment: String?, listingId: String?, type: UserRatingType,
                      completion: UserRatingCompletion?)
    /**
     Updates the given rating

     - parameter rating:     the rating to update
     - parameter value:      new rating stars value
     - parameter comment:    new rating comment
     - parameter completion: the completion closure
     */
    func updateRating(_ rating: UserRating, value: Int?, comment: String?, completion: UserRatingCompletion?)

    /**
     Reports a received rating

     - parameter rating:     the rating to report
     - parameter completion: the completion closure
    */
    func reportRating(_ rating: UserRating, completion: UserRatingCompletion?)
}
