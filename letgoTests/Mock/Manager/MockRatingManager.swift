//
//  MockRatingManager.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


@testable import LetGoGodMode

struct MockRatingManager: RatingManager {
    var shouldShowRating: Bool = true
    func userDidRate() { }
    func userDidRemindLater() { }
}
