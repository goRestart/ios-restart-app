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

enum RateUserState: Equatable {
    case review(positive: Bool)
    case comment
}

func ==(lhs: RateUserState, rhs: RateUserState) -> Bool {
    switch (lhs, rhs) {
    case (.review(let rPos), .review(let lPos)): return rPos == lPos
    case (.comment, .comment): return true
    default: return false
    }
}

protocol RateUserViewModelDelegate: BaseViewModelDelegate {
    func vmUpdateDescription(_ description: String?)
    func vmUpdateTags()
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
    let state = Variable<RateUserState>(.review(positive: true))
    let sendText = Variable<String?>(nil)
    let sendEnabled = Variable<Bool>(false)
    let rating = Variable<Int?>(nil)
    let description = Variable<String?>(nil)
    let descriptionPlaceholder = LGLocalizedString.userRatingReviewPlaceholderOptional
    let descriptionCharLimit = Variable<Int>(Constants.userRatingDescriptionMaxLength)

    fileprivate let userRatingRepository: UserRatingRepository
    fileprivate let tracker: Tracker
    fileprivate let source: RateUserSource
    fileprivate let data: RateUserData
    fileprivate var previousRating: UserRating?
    fileprivate let isReviewPositive = Variable<Bool>(true)
    fileprivate let selectedTagIndexes = CollectionVariable<Int>([])
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
}


// MARK: - Public methods
// MARK: > Actions

extension RateUserViewModel {
    func closeButtonPressed() {
        navigator?.rateUserCancel()
    }
    
    func skipButtonPressed() {
        navigator?.rateUserSkip()
    }
    
    func ratingStarPressed(_ rating: Int) {
        self.rating.value = rating
    }
    
    func sendButtonPressed() {
        guard let rating = rating.value, sendEnabled.value else { return }
        
        let ratingCompletion: UserRatingCompletion = { [weak self] result in
            guard let strongSelf = self else { return }
            
            strongSelf.isLoading.value = false
            if let rating = result.value {
                strongSelf.previousRating = rating
                switch strongSelf.state.value {
                case .review:
                    strongSelf.didFinishRating(rating: rating)
                case .comment:
                    strongSelf.didFinishCommenting(rating: rating)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
                     .wsChatError:
                    message = LGLocalizedString.commonError
                }
                strongSelf.delegate?.vmShowAutoFadingMessage(message, completion: nil)
            }
        }
        
        isLoading.value = true
        
        let comment = makeComment()
        if let previousRating = previousRating {
            userRatingRepository.updateRating(previousRating, value: rating, comment: comment,
                                              completion: ratingCompletion)
        } else {
            userRatingRepository.createRating(data.userId, value: rating, comment: comment,
                                              type: data.ratingType, completion: ratingCompletion)
        }
    }
    
    func setDescription(text: String) -> Bool {
        let descriptionWithoutEmoji = text.stringByRemovingEmoji()        
        if descriptionWithoutEmoji != descriptionPlaceholder {
            description.value = descriptionWithoutEmoji.isEmpty ? nil : descriptionWithoutEmoji
        }
        return !text.hasEmojis()
    }
}


// MARK: > Tags

extension RateUserViewModel {
    var numberOfTags: Int {
        return tagTitles.count
    }
    
    func titleForTagAt(index: Int) -> String? {
        guard 0..<numberOfTags ~= index else { return nil }
        return tagTitles[index]
    }
    
    func isSelectedTagAt(index: Int) -> Bool {
        return selectedTagIndexes.value.contains(index)
    }
    
    func selectTagAt(index: Int) {
        guard !isSelectedTagAt(index: index) else { return }
        selectedTagIndexes.append(index)
    }
    
    func deselectTagAt(index: Int) {
        guard let arrayIndex = selectedTagIndexes.value.index(of: index) else { return }
        selectedTagIndexes.removeAtIndex(arrayIndex)
    }
}


// MARK: - Private methods
// MARK: > Rx

fileprivate extension RateUserViewModel {
    func setupRx() {
        rating.asObservable()
            .map { (stars: Int?) -> Bool in
                guard let stars = stars else { return true }
                return stars >= Constants.userRatingMinStarsPositive }
            .distinctUntilChanged()
            .bindTo(isReviewPositive).addDisposableTo(disposeBag)
        
        isReviewPositive.asObservable().subscribeNext { [weak self] positive in
            self?.reviewStateDidChange(positive: positive)
        }.addDisposableTo(disposeBag)
        
        Observable.combineLatest(isLoading.asObservable(),
                                 state.asObservable(), resultSelector: { $0 })
            .map { [weak self] (isLoading, state) -> String? in
                guard let strongSelf = self, !isLoading else { return nil }
                
                switch state {
                case .review:
                    return LGLocalizedString.userRatingReviewButton
                case .comment:
                    if let _ = strongSelf.previousRating {
                        return LGLocalizedString.userRatingUpdateCommentButton
                    } else {
                        return LGLocalizedString.userRatingAddCommentButton
                    }
                }
            }.bindTo(sendText).addDisposableTo(disposeBag)
        
        let ratingValid = rating.asObservable()
            .map { $0 != nil }
            .distinctUntilChanged()
        let tagsValid = selectedTagIndexes.observable
            .map { !$0.isEmpty }
            .distinctUntilChanged()
        let comment = Observable.combineLatest(description.asObservable(), selectedTagIndexes.observable) { $0 }
            .map { [weak self] _ in return self?.makeComment() }
        let commentLength = comment.asObservable()
            .map { Constants.userRatingDescriptionMaxLength - ($0?.characters.count ?? 0) }
            .distinctUntilChanged()
        let commentValid = commentLength.map { $0 >= 0 }
            
        Observable.combineLatest(isLoading.asObservable(),
                                 state.asObservable(),
                                 tagsValid,
                                 ratingValid,
                                 commentValid, resultSelector: { $0 })
            .map { (isLoading, state, tagsValid, ratingValid, commentValid) -> Bool in
                guard !isLoading else { return false }
                
                switch state {
                case .review:
                    return ratingValid && tagsValid
                case .comment:
                    return ratingValid && tagsValid && commentValid
                }
            }
            .distinctUntilChanged()
            .bindTo(sendEnabled).addDisposableTo(disposeBag)
        
        commentLength.bindTo(descriptionCharLimit).addDisposableTo(disposeBag)
    }
}


// MARK: > State

fileprivate extension RateUserViewModel {
    func reviewStateDidChange(positive: Bool) {
        switch state.value {
        case .review:
            selectedTagIndexes.removeAll()
            state.value = .review(positive: positive)
        case .comment:
            return
        }
    }
    
    func didFinishRating(rating: UserRating) {
        state.value = .comment
        trackComplete(rating: rating)
    }
    
    func didFinishCommenting(rating: UserRating) {
        trackComplete(rating: rating)
        delegate?.vmShowAutoFadingMessage(LGLocalizedString.userRatingReviewSendSuccess) { [weak self] in
            self?.navigator?.rateUserFinish(withRating: self?.rating.value ?? 0)
        }
    }
}


// MARK: > Requests

fileprivate extension RateUserViewModel {
    func retrievePreviousRating() {
        isLoading.value = true
        userRatingRepository.show(data.userId, type: data.ratingType) { [weak self] result in
            self?.isLoading.value = false
            guard let userRating = result.value else { return }
            self?.previousRating = userRating
            self?.rating.value = userRating.value
            
            let description: String?
            let tagIdxs: [Int]
            if let comment = userRating.comment {
                description = comment.trimUserRatingTags()
                
                if userRating.value >= Constants.userRatingMinStarsPositive {
                    let positiveTags = PositiveUserRatingTag.make(string: comment)
                    let allPositiveTags = PositiveUserRatingTag.allValues
                    tagIdxs = positiveTags.flatMap { allPositiveTags.index(of: $0) }
                } else {
                    let negativeTags = NegativeUserRatingTag.make(string: comment)
                    let allNegativeTags = NegativeUserRatingTag.allValues
                    tagIdxs = negativeTags.flatMap { allNegativeTags.index(of: $0) }
                }
            } else {
                description = nil
                tagIdxs = []
            }
            
            self?.delegate?.vmUpdateDescription(description)
            self?.description.value = description
            
            self?.selectedTagIndexes.value = tagIdxs
            self?.delegate?.vmUpdateTags()
        }
    }
}


// MARK: > Helpers

fileprivate extension RateUserViewModel {
    var tagTitles: [String] {
        if isReviewPositive.value {
            return PositiveUserRatingTag.allValues.map { $0.localizedText }
        } else {
            return NegativeUserRatingTag.allValues.map { $0.localizedText }
        }
    }
    
    func makeComment() -> String {
        let tagsString: [String]
        if isReviewPositive.value {
            tagsString = PositiveUserRatingTag.allValues
                .enumerated()
                .filter { (index, _) in return selectedTagIndexes.value.contains(index) }
                .map { (_, item) in return item.localizedText }
            
        } else {
            tagsString = NegativeUserRatingTag.allValues
                .enumerated()
                .filter { (index, _) in return selectedTagIndexes.value.contains(index) }
                .map { (_, item) in return item.localizedText }
        }
        return String.make(tagsString: tagsString, comment: description.value)
    }
}


// MARK: > Tracking

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

    func trackComplete(rating: UserRating) {
        let hasComments = !(rating.comment ?? "").isEmpty
        let event = TrackerEvent.userRatingComplete(data.userId, typePage: EventParameterTypePage(source: source),
                                                    rating: rating.value, hasComments: hasComments)
        tracker.trackEvent(event)
    }
}


