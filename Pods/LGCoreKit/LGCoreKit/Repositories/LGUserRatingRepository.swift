//
//  LGUserRatingRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


public class LGUserRatingRepository: UserRatingRepository {

    let dataSource: UserRatingDataSource
    let myUserRepository: MyUserRepository


    // MARK: - Lifecycle

    init(dataSource: UserRatingDataSource, myUserRepository: MyUserRepository) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
    }


    // MARK: - Public methods

    /**
     Retrieves all ratings the given user has received

     - parameter userId: id of the user to retrieve ratings
     - parameter offset: Pagination offset
     - parameter limit: Number of items in each page
     - parameter completion: The completion closure
     */
    public func index(_ userId: String, offset: Int, limit: Int, completion: UserRatingsCompletion?) {
        dataSource.index(userId, offset: offset, limit: limit) { result in
            handleApiResult(result, completion: completion)
        }
    }

    /**
     Retrieves the rating the logged user has made to the given user

     - parameter ratingId: id of the rating to retrieve
     - parameter completion: The completion closure
     */
    public func show(_ ratingId: String, completion: UserRatingCompletion?) {
        dataSource.show(ratingId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    /**
     Retrieves the rating the logged user has made to the given user

     - parameter userId: id of the user to retrieve rating
     - parameter type: Rating type
     - parameter completion: The completion closure
     */
    public func show(_ userId: String, type: UserRatingType, completion: UserRatingCompletion?) {
        guard let userFromId = myUserRepository.myUser?.objectId else {
            completion?(UserRatingResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        dataSource.show(userId, userFromId: userFromId, type: type) { result in
            handleApiResult(result, completion: completion)
        }
    }

    /**
     Adds a new rating to the given user

     - parameter userId:     user to rate
     - parameter value:      rating stars value
     - parameter comment:    rating comment
     - parameter type:       rating type (Conversation, Seller(productId), Buyer(productId))
     - parameter completion: The completion closure
     */
    public func createRating(_ userId: String, value: Int, comment: String?, type: UserRatingType,
                             completion: UserRatingCompletion?) {
        guard let userFromId = myUserRepository.myUser?.objectId else {
            completion?(UserRatingResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.create(userId, userFromId: userFromId, value: value, comment: comment, type: type) {
            result in
            handleApiResult(result, completion: completion)
        }
    }

    /**
     Updates the given rating

     - parameter rating:     the rating to update
     - parameter value:      new rating stars value
     - parameter comment:    new rating comment
     - parameter completion: the completion closure
     */
    public func updateRating(_ rating: UserRating, value: Int?, comment: String?, completion: UserRatingCompletion?) {
        guard let myUserId = myUserRepository.myUser?.objectId else {
            completion?(UserRatingResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        guard let ratingId = rating.objectId else {
            completion?(UserRatingResult(error: .internalError(message: "Missing objectId in rating object")))
            return
        }
        guard rating.userFrom.objectId == myUserId else {
            completion?(UserRatingResult(error: .internalError(message: "Rating doesn't belong to MyUser")))
            return
        }
        dataSource.update(ratingId, value: value, comment: comment) { result in
            handleApiResult(result, completion: completion)
        }
    }

    /**
     Reports a received rating

     - parameter rating:     the rating to report
     - parameter completion: the completion closure
     */
    public func reportRating(_ rating: UserRating, completion: UserRatingCompletion?) {
        guard let myUserId = myUserRepository.myUser?.objectId else {
            completion?(UserRatingResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        guard let ratingId = rating.objectId else {
            completion?(UserRatingResult(error: .internalError(message: "Missing objectId in rating object")))
            return
        }
        guard rating.userToId == myUserId else {
            completion?(UserRatingResult(error: .internalError(message: "MyUser is not the rating receiver")))
            return
        }
        dataSource.report(ratingId) { result in
            handleApiResult(result, completion: completion)
        }
    }
}
