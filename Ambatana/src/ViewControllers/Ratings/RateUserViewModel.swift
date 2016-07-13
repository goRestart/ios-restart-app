//
//  UserRatingViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

protocol RateUserViewModelDelegate: BaseViewModelDelegate {
    func vmUpdateDescription(description: String)
}

class RateUserViewModel: BaseViewModel {

    weak var delegate: RateUserViewModelDelegate?
    weak var navigator: RateUserNavigator?

    let userAvatar: NSURL?
    let userName: String?
    var infoText: String {
        if let userName = userName where !userName.isEmpty {
            return LGLocalizedString.userRatingMessageWName(userName)
        } else {
            return LGLocalizedString.userRatingMessageWoName
        }
    }

    let isLoading = Variable<Bool>(false)
    let sendEnabled = Variable<Bool>(false)
    let rating = Variable<Int?>(nil)
    let description = Variable<String?>(nil)
    let descriptionCharLimit = Variable<Int>(Constants.userRatingDescriptionMaxLength)

    private let userId: String
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(userId: String, userAvatar: NSURL?, userName: String?) {
        self.userId = userId
        self.userAvatar = userAvatar
        self.userName = userName

        super.init()

        self.setupRx()
    }


    // MARK: - Actions

    func closeButtonPressed() {
        navigator?.rateUserCancel()
    }

    func ratingStarPressed(rating: Int) {
        self.rating.value = rating
    }

    func publishButtonPressed() {
        
    }


    // MARK: - Private methods

    private func setupRx() {
        Observable.combineLatest(isLoading.asObservable(), rating.asObservable(),
            description.asObservable(), resultSelector: { $0 })
            .map { (loading, rating, description) in
                guard !loading, let rating = rating else { return false }
                guard rating < 4 else { return true }
                guard let description = description where !description.isEmpty &&
                    description.characters.count <= Constants.userRatingDescriptionMaxLength else { return false }
                return true
            }.bindTo(sendEnabled).addDisposableTo(disposeBag)

        description.asObservable().map { Constants.userRatingDescriptionMaxLength - ($0?.characters.count ?? 0) }
            .bindTo(descriptionCharLimit).addDisposableTo(disposeBag)
    }

}