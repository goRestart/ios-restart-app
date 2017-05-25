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
    let userAvatar: URL?
    let userName: String?
    let ratingType: UserRatingType

    init?(user: UserListing) {
        guard let userId = user.objectId else { return nil }
        self.userId = userId
        self.userAvatar = user.avatar?.fileURL
        self.userName = user.name
        self.ratingType = .conversation
    }

    init?(interlocutor: ChatInterlocutor) {
        guard let userId = interlocutor.objectId else { return nil }
        self.userId = userId
        self.userAvatar = interlocutor.avatar?.fileURL
        self.userName = interlocutor.name
        self.ratingType = .conversation
    }
}

enum RateUserSource {
    case chat, deepLink, userRatingList, markAsSold
}

protocol RateUserViewModelDelegate: BaseViewModelDelegate {
    func vmUpdateDescription(_ description: String?)
    func vmUpdateDescriptionPlaceholder(_ placeholder: String)
    func vmReloadTags()
}

class RateUserViewModel: BaseViewModel {

    weak var delegate: RateUserViewModelDelegate?
    weak var navigator: RateUserNavigator?

    var userAvatar: URL? {
        return data.userAvatar
    }
    var userName: String? {
        return data.userName
    }
    var infoText: String {
        if let userName = userName, !userName.isEmpty {
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
    fileprivate let tracker: Tracker
    fileprivate let source: RateUserSource
    fileprivate let data: RateUserData
    fileprivate var previousRating: UserRating?
    fileprivate var selectedTagIndexes: Set<Int>
    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(source: RateUserSource, data: RateUserData) {
        self.init(source: source, data: data, userRatingRepository: Core.userRatingRepository, tracker: TrackerProxy.sharedInstance)
    }

    init(source: RateUserSource, data: RateUserData, userRatingRepository: UserRatingRepository, tracker: Tracker) {
        self.source = source
        self.data = data
        self.userRatingRepository = userRatingRepository
        self.tracker = tracker
        self.selectedTagIndexes = Set<Int>()

        super.init()

        self.setupRx()
        self.trackStart()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            retrievePreviousRating()
        }
    }

    // MARK: - Actions

    func closeButtonPressed() {
        navigator?.rateUserCancel()
    }

    func skipButtonPressed() {
        navigator?.rateUserSkip()
    }

    func ratingStarPressed(_ rating: Int) {
        self.rating.value = rating
    }

    func publishButtonPressed() {
        guard let rating = rating.value, sendEnabled.value else { return }

        let ratingCompletion: UserRatingCompletion = { [weak self] result in
            self?.isLoading.value = false
            if let rating = result.value {
                self?.finishedRating(rating)
            } else if let error = result.error {
                let message: String
                switch error {
                case .network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError:
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

    
    // MARK: - Tags
    
    var numberOfTags: Int {
        return tagTitles.count
    }
    
    func titleForTagAt(index: Int) -> String? {
        guard 0..<numberOfTags ~= index else { return nil }
        return tagTitles[index]
    }
    
    func isTagSelectedAt(index: Int) -> Bool {
        guard 0..<numberOfTags ~= index else { return false }
        return selectedTagIndexes.contains(index)
    }
    
    func selectTagAt(index: Int) {
        guard !isTagSelectedAt(index: index) else { return }
        selectedTagIndexes.insert(index)
    }
    
    func deselectTagAt(index: Int) {
        guard isTagSelectedAt(index: index) else { return }
        selectedTagIndexes.remove(index)
    }
    

    // MARK: - Private methods

    private func setupRx() {
        Observable.combineLatest(isLoading.asObservable(), rating.asObservable(),
            description.asObservable(), resultSelector: { $0 })
            .map { (loading, rating, description) in
                guard !loading, let rating = rating else { return false }
                guard rating < Constants.userRatingMinStarsPositive else { return true }
                guard let description = description, !description.isEmpty &&
                    description.characters.count <= Constants.userRatingDescriptionMaxLength else { return false }
                return true
            }.bindTo(sendEnabled).addDisposableTo(disposeBag)

        rating.asObservable().map {
                if let stars = $0 {
                    return stars < Constants.userRatingMinStarsPositive ?
                        LGLocalizedString.userRatingReviewPlaceholderMandatory :
                        LGLocalizedString.userRatingReviewPlaceholderOptional
                } else {
                    return LGLocalizedString.userRatingReviewPlaceholder
                }
            }.bindNext { [weak self] placeholder in
                self?.delegate?.vmUpdateDescriptionPlaceholder(placeholder)
            }.addDisposableTo(disposeBag)
        
        let positiveTagsEnabled = rating.asObservable().map { (stars: Int?) -> Bool in
            guard let stars = stars else { return true }
            return stars >= Constants.userRatingMinStarsPositive
        }.distinctUntilChanged()
        
        positiveTagsEnabled.subscribeNext { [weak self] _ in
            self?.delegate?.vmReloadTags()
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

    private func finishedRating(_ userRating: UserRating) {
        trackComplete(userRating)
        delegate?.vmShowAutoFadingMessage(LGLocalizedString.userRatingReviewSendSuccess) { [weak self] in
            self?.navigator?.rateUserFinish(withRating: self?.rating.value ?? 0)
        }
    }
    
    private var tagTitles: [String] {
        guard let rating = rating.value else { return PositiveUserRatingTag.allValues.map { $0.localizedText } }
        
        if rating >= Constants.userRatingMinStarsPositive {
            return PositiveUserRatingTag.allValues.map { $0.localizedText }
        } else {
            return NegativeUserRatingTag.allValues.map { $0.localizedText }
        }
    }
}


// MARK: - Tracking

fileprivate extension EventParameterTypePage {
    init(source: RateUserSource) {
        switch source {
        case .chat:
            self = .chat
        case .deepLink:
            self = .external
        case .userRatingList:
            self = .userRatingList
        case .markAsSold:
            self = .productSold
        }
    }
}

fileprivate extension RateUserViewModel {
    func trackStart() {
        let event = TrackerEvent.userRatingStart(data.userId, typePage: EventParameterTypePage(source: source))
        tracker.trackEvent(event)
    }

    func trackComplete(_ rating: UserRating) {
        let hasComments = !(rating.comment ?? "").isEmpty
        let event = TrackerEvent.userRatingComplete(data.userId, typePage: EventParameterTypePage(source: source),
                                                    rating: rating.value, hasComments: hasComments)
        tracker.trackEvent(event)
    }
}


