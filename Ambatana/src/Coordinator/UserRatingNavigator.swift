//
//  UserRatingNavigator.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol RateBuyersNavigator: class {
    func rateBuyersCancel()
    func rateBuyersFinish(withUser: UserProduct)
    func rateBuyersFinishNotOnLetgo()
}

protocol RateUserNavigator: class {
    func rateUserCancel()
    func rateUserSkip()
    func rateUserFinish(withRating rating: Int)
}
