//
//  UserRatingDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 14/07/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias UserRatingsDataSourceResult = Result<[UserRating], ApiError>
typealias UserRatingsDataSourceCompletion = UserRatingsDataSourceResult -> Void

typealias UserRatingDataSourceResult = Result<UserRating, ApiError>
typealias UserRatingDataSourceCompletion = UserRatingDataSourceResult -> Void

typealias UserRatingDataSourceEmptyResult = Result<Void, ApiError>
typealias UserRatingDataSourceEmptyCompletion = UserRatingDataSourceEmptyResult -> Void

protocol UserRatingDataSource {
    func index(userId: String, offset: Int, limit: Int, completion: UserRatingsDataSourceCompletion?)
    func show(ratingId: String, completion: UserRatingDataSourceCompletion?)
    func show(userId: String, userFromId: String, type: UserRatingType, completion: UserRatingDataSourceCompletion?)
    func create(userId: String, userFromId: String, value: Int, comment: String?, type: UserRatingType, completion: UserRatingDataSourceCompletion?)
    func update(ratingId: String, value: Int?, comment: String?, completion: UserRatingDataSourceCompletion?)
    func report(ratingId: String, completion: UserRatingDataSourceEmptyCompletion?)
}
