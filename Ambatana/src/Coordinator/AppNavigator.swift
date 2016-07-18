//
//  AppNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 29/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol AppNavigatorDelegate: class {
    func appNavigatorDidOpenApp()
}

protocol AppNavigator: class {
    weak var delegate: AppNavigatorDelegate? { get }
    
    func open()
    func openForceUpdateAlertIfNeeded()
    func openSell(source: PostingSource)
    func openUserRating(data: RateUserData)
}
