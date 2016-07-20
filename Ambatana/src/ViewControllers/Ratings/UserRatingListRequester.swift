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
    func requesterDidLoadUserRatings(ratings: [UserRating])
    func requesterDidFailLoadingUserRatings()
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

    convenience init(userId: String) {
        self.init(userRatingRepository: Core.userRatingRepository, userId: userId)
    }

    init(userRatingRepository: UserRatingRepository, userId: String) {
        self.userRatingRepository = userRatingRepository
        self.userId = userId
    }

}

extension UserRatingListRequester: Paginable {

    func retrievePage(page: Int) {

        delegate?.requesterDidLoadUserRatings(MockUserRating.mockupRatings())

        // TODO: ⚠️ Uncomment once we have the right URLs and LGCoreKit is fixed
//        isLoading = true
//        userRatingRepository.index(userId, offset: objectCount, limit: resultsPerPage) { [weak self] result in
//            if let value = result.value {
//                self?.delegate?.requesterDidLoadUserRatings(value)
//                self?.objectCount += value.count
//            } else if let _ = result.error {
//                self?.delegate?.requesterDidFailLoadingUserRatings()
//            }
//            self?.isLoading = false
//        }
    }


}

// TODO: ⚠️ Delete once we have the right URLs and LGCoreKit is fixed

struct MockUserRating: UserRating {

    let objectId: String?
    let userToId: String
    let userFrom: User
    let type: UserRatingType
    let value: Int
    let comment: String?
    let status: UserRatingStatus
    let createdAt: NSDate
    let updatedAt: NSDate

    init(objectId: String, userToId: String, userFrom: User, type: UserRatingType, value: Int, comment: String?,
         status: UserRatingStatus, createdAt: NSDate, updatedAt: NSDate) {
        self.objectId = objectId
        self.userToId = userToId
        self.userFrom = userFrom
        self.type = type
        self.value = value
        self.comment = comment
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func mockupRatings() -> [UserRating] {

        let user1 = MockUserForRating(objectId: "1234", name: "A user 1", avatar: nil,
                           postalAddress: PostalAddress.emptyAddress(), accounts: nil, status: .Active, isDummy: false)
        let ratingConv = MockUserRating(objectId: "abcd", userToId: "0000", userFrom: user1, type: .Conversation, value: 3, comment: nil, status: .Published , createdAt: NSDate(), updatedAt: NSDate())

        let user2 = MockUserForRating(objectId: "5678", name: "M user 2", avatar: nil,
                                      postalAddress: PostalAddress.emptyAddress(), accounts: nil, status: .Active, isDummy: false)
        let ratingSell = MockUserRating(objectId: "efgh", userToId: "0000", userFrom: user2, type: .Seller(productId: "rrrrr"), value: 2, comment: "Super long comment, Super long comment, Super long comment, Super long comment, Super long comment, Super long comment, Super long comment, Super long comment, Super long comment, Super long comment, Super long comment, Super long comment, Super long comment, Super long comment, Super long comment, Super long comment. Koniek.", status: .Published , createdAt: NSDate(), updatedAt: NSDate())


        let user3 = MockUserForRating(objectId: "9012", name: "Z user 3", avatar: nil,
                                      postalAddress: PostalAddress.emptyAddress(), accounts: nil, status: .Active, isDummy: false)
        let ratingBuy = MockUserRating(objectId: "ijkl", userToId: "0000", userFrom: user3, type: .Buyer(productId: "pfffff"), value: 5, comment: "Short comment!", status: .Published , createdAt: NSDate(), updatedAt: NSDate())


        let user4 = MockUserForRating(objectId: "5678", name: "3 user 4", avatar: nil,
                                      postalAddress: PostalAddress.emptyAddress(), accounts: nil, status: .Active, isDummy: false)
        let ratingConv2 = MockUserRating(objectId: "efgh", userToId: "0000", userFrom: user4, type: .Conversation, value: 2, comment: nil, status: .Published , createdAt: NSDate(), updatedAt: NSDate())


        let user5 = MockUserForRating(objectId: "5678", name: "G user 5", avatar: nil,
                                      postalAddress: PostalAddress.emptyAddress(), accounts: nil, status: .Active, isDummy: false)
        let ratingConv3 = MockUserRating(objectId: "efgh", userToId: "0000", userFrom: user5, type: .Conversation, value: 0, comment: "Lorem fistrum se calle ustée ahorarr ese hombree amatomaa no puedor pupita pupita al ataquerl te va a hasé pupitaa apetecan.", status: .Published , createdAt: NSDate(), updatedAt: NSDate())


        let ratingSell2 = MockUserRating(objectId: "efgh", userToId: "0000", userFrom: user2, type: .Seller(productId: "uuuuu"), value: 4, comment: "Rating Also from user 2, Tiene musho peligro diodeno qué dise usteer mamaar te voy a borrar el cerito.  Llevame al sircoo ese que llega va usté muy cargadoo ahorarr ese pedazo de papaar papaar tiene musho peligro te voy a borrar el cerito a wan papaar papaar. ", status: .Published , createdAt: NSDate(), updatedAt: NSDate())


        return [ratingConv, ratingSell, ratingBuy, ratingConv2, ratingConv3, ratingSell2]
    }
}

public struct MockUserForRating: User {

    // Global iVars
    public var objectId: String?

    // User iVars
    public var name: String?
    public var avatar: File?
    public var postalAddress: PostalAddress
    public var accounts: [Account]?
    public var status: UserStatus
    public var isDummy: Bool
    public var ratingAverage: Float?     // TODO: When switching to bouncer only make ratings & accounts non-optional
    public var ratingCount: Int?

    init(objectId: String?, name: String?, avatar: String?, postalAddress: PostalAddress, accounts: [Account]?,
         status: UserStatus?, isDummy: Bool) {
        self.objectId = objectId
        self.name = name
        self.avatar = LGFile(id: nil, urlString: avatar)
        self.postalAddress = postalAddress
        self.accounts = accounts?.map { $0 as Account }
        self.status = status ?? .Active
        self.isDummy = isDummy
    }
}