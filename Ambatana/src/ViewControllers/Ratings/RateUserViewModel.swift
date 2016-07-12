//
//  UserRatingViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol RateUserViewModelDelegate: BaseViewModelDelegate {

}

class RateUserViewModel: BaseViewModel {

    weak var delegate: RateUserViewModelDelegate?
    weak var navigator: RateUserNavigator?


    private let userId: String
    let userAvatar: NSURL?
    let userName: String?

    init(userId: String, userAvatar: NSURL?, userName: String?) {
        self.userId = userId
        self.userAvatar = userAvatar
        self.userName = userName
    }



    // MARK: - Actions

    func closeButtonPressed() {
        navigator?.rateUserCancel()
    }
}