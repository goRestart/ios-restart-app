//
//  OnboardingNavigator.swift
//  LetGo
//
//  Created by Eli Kohen on 13/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol TourLoginNavigator: class {
    func tourLoginFinish()
}

protocol TourNotificationsNavigator: class {
    func tourNotificationsFinish()
}

protocol TourLocationNavigator: class {
    func tourLocationFinish()
}

protocol TourPostingNavigator: class {
    func tourPostingClose()
    func tourPostingPost(fromCamera: Bool)
}
