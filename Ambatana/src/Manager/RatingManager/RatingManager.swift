//
//  RatingManager.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


protocol RatingManager {
    var shouldShowRating: Bool { get }
    func userDidRate()
    func userDidRemindLater()
}
