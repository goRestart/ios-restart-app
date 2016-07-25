//
//  UserRatingViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

struct RateUserData {
    let userId: String
    let userAvatar: NSURL?
    let userName: String?
    let ratingType: UserRatingType

    init?(user: User) {
        guard let userId = user.objectId else { return nil }
        self.userId = userId
        self.userAvatar = user.avatar?.fileURL
        self.userName = user.name
        self.ratingType = .Conversation
    }

    init?(interlocutor: ChatInterlocutor) {
        guard let userId = interlocutor.objectId else { return nil }
        self.userId = userId
        self.userAvatar = interlocutor.avatar?.fileURL
        self.userName = interlocutor.name
        self.ratingType = .Conversation
    }
}

enum RateUserSource {
    case Chat, DeepLink, UserRatingList
}

protocol RateUserViewModelDelegate: BaseViewModelDelegate {
    func vmUpdateDescription(description: String?)
    func vmUpdateDescriptionPlaceholder(placeholder: String)
}

class RateUserViewModel: BaseViewModel {

    weak var delegate: RateUserViewModelDelegate?
    weak var navigator: RateUserNavigator?

    var userAvatar: NSURL? {
        return data.userAvatar
    }
    var userName: String? {
        return data.userName
    }
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
    let descriptionPlaceholder = Variable<String>(LGLocalizedString.userRatingReviewPlaceholder)
    let descriptionCharLimit = Variable<Int>(Constants.userRatingDescriptionMaxLength)

    private let userRatingRepository: UserRatingRepository
    private let tracker: Tracker
    private let source: RateUserSource
    private let data: RateUserData
    private var previousRating: UserRating?
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(source: RateUserSource, data: RateUserData) {
        self.init(source: source, data: data, userRatingRepository: Core.userRatingRepository, tracker: TrackerProxy.sharedInstance)
    }

    init(source: RateUserSource, data: RateUserData, userRatingRepository: UserRatingRepository, tracker: Tracker) {
        self.source = source
        self.data = data
        self.userRatingRepository = userRatingRepository
        self.tracker = tracker

        super.init()

        self.setupRx()
        self.trackStart()
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            retrievePreviousRating()
        }
    }

    // MARK: - Actions

    func closeButtonPressed() {
        navigator?.rateUserCancel()
    }

    func ratingStarPressed(rating: Int) {
        self.rating.value = rating
    }

    func publishButtonPressed() {
        guard let rating = rating.value where sendEnabled.value else { return }

        let ratingCompletion: UserRatingCompletion = { [weak self] result in
            self?.isLoading.value = false
            if let rating = result.value {
                self?.finishedRating(rating)
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified:
                    message = LGLocalizedString.commonError
                }
                self?.delegate?.vmShowAutoFadingMessage(message, completion: nil)
            }
        }

        self.isLoading.value = true
        if let previousRating = previousRating {
            userRatingRepository.updateRating(previousRating, value: rating, comment: description.value,
                                              completion: ratingCompletion)
        } else {
            userRatingRepository.createRating(data.userId, value: rating, comment: description.value,
                                              type: data.ratingType, completion: ratingCompletion)
        }
    }


    // MARK: - Private methods

    private func setupRx() {
        Observable.combineLatest(isLoading.asObservable(), rating.asObservable(),
            description.asObservable(), resultSelector: { $0 })
            .map { (loading, rating, description) in
                guard !loading, let rating = rating else { return false }
                guard rating < 4 else { return true } // 4-5 stars allows rating without description
                guard let description = description where !description.isEmpty &&
                    description.characters.count <= Constants.userRatingDescriptionMaxLength else { return false }
                return true
            }.bindTo(sendEnabled).addDisposableTo(disposeBag)

        rating.asObservable().map {
                ($0 ?? 0) < 4 ? LGLocalizedString.userRatingReviewPlaceholder :
                    LGLocalizedString.userRatingReviewPlaceholderOptional
            }.bindNext { [weak self] placeholder in
                self?.delegate?.vmUpdateDescriptionPlaceholder(placeholder)
            }.addDisposableTo(disposeBag)

        description.asObservable().map { Constants.userRatingDescriptionMaxLength - ($0?.characters.count ?? 0) }
            .bindTo(descriptionCharLimit).addDisposableTo(disposeBag)
    }

    private func retrievePreviousRating() {
        isLoading.value = true
        userRatingRepository.show(data.userId, type: data.ratingType) { [weak self] result in
            self?.isLoading.value = false
            guard let userRating = result.value else { return }
            self?.previousRating = userRating
            self?.rating.value = userRating.value
            self?.description.value = userRating.comment
            self?.delegate?.vmUpdateDescription(userRating.comment)
        }
    }

    private func finishedRating(userRating: UserRating) {
        trackComplete(userRating)
        delegate?.vmShowAutoFadingMessage(LGLocalizedString.userRatingReviewSendSuccess) { [weak self] in
            self?.navigator?.rateUserFinish()
        }
    }
}


// MARK: - Tracking

private extension EventParameterTypePage {
    init(source: RateUserSource) {
        switch source {
        case .Chat:
            self = .Chat
        case .DeepLink:
            self = .External
        case .UserRatingList:
            self = .UserRatingList
        }
    }
}

private extension RateUserViewModel {
    func trackStart() {
        let event = TrackerEvent.userRatingStart(data.userId, typePage: EventParameterTypePage(source: source))
        tracker.trackEvent(event)
    }

    func trackComplete(rating: UserRating) {
        let hasComments = !(rating.comment ?? "").isEmpty
        let event = TrackerEvent.userRatingComplete(data.userId, typePage: EventParameterTypePage(source: source),
                                                    rating: rating.value, hasComments: hasComments)
        tracker.trackEvent(event)
    }
}


