//
//  UserRatingNavigator.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol RateUserNavigator: class {
    func rateUserCancel()
    func rateUserFinish(withRating rating: Int)
}
