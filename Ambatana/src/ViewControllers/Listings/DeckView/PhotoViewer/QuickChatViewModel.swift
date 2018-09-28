import Foundation
import RxSwift
import RxCocoa
import LGCoreKit
import LGComponents

struct ProChatViewState {
    let message: String
    let icon: UIImage?
    let action: (()->())?
}

struct QuickAnswersViewState {
    let quickAnswers: [QuickAnswer]
}

struct QuickChatViewState {
    let quickAnswersState: QuickAnswersViewState?
    let proState: ProChatViewState?
    let isInterested: Bool
}

struct SellerTrackingInfo {
    var source: EventParameterListingVisitSource
    var feedPosition: EventParameterFeedPosition
}

final class QuickChatViewModel: BaseViewModel, DirectAnswersHorizontalViewDelegate {
    var listingViewModel: ListingViewModel? {
        didSet { setupRx() }
    }
    
    var sectionFeedChatTrackingInfo: SectionedFeedChatTrackingInfo?
    var sellerTrackInfo: SellerTrackingInfo?

    private var activeDisposeBag = DisposeBag()
    var objectCount: Int { return directChatMessages.value.count }
    fileprivate let chatState = BehaviorRelay<QuickChatViewState>(value: QuickChatViewState(quickAnswersState: nil,
                                                                                            proState: nil,
                                                                                            isInterested: false))
    fileprivate let directChatMessages = CollectionVariable<ChatViewMessage>([])

    private func setupRx() {
        activeDisposeBag = DisposeBag()

        guard let listingVM = listingViewModel else { return }

        let isInterested = listingVM.isInterested.asDriver().distinctUntilChanged()

        Driver.combineLatest(rx.quickAnswersViewState(listingVM: listingVM),
                             rx.proChatViewState(listingVM: listingVM),
                             isInterested) { ($0, $1, $2) }
            .map { return QuickChatViewState(quickAnswersState: $0, proState: $1, isInterested: $2) }
            .drive(chatState)
            .disposed(by: activeDisposeBag)
        listingVM.directChatMessages
            .changesObservable
            .subscribe(onNext: { [weak self] (change) in
            self?.performCollectionChange(change: change)
        }).disposed(by: activeDisposeBag)
    }

    func message(at index: Int) -> ChatViewMessage? {
        return directChatMessages.value[safeAt: index] ?? nil
    }

    func messageExists(_ messageID: String) -> Bool {
        return directChatMessages.value.filter({ $0.objectId == messageID }).count >= 1
    }

    func send(directMessage: String, isDefaultText: Bool) {
        listingViewModel?.sendDirectMessage(directMessage,
                                            isDefaultText: isDefaultText,
                                            trackingInfo: sectionFeedChatTrackingInfo)
    }

    func performCollectionChange(change: CollectionChange<ChatViewMessage>) {
        switch change {
        case let .insert(index, value):
            directChatMessages.insert(value, atIndex: index)
        case let .remove(index, _):
            directChatMessages.removeAtIndex(index)
        case let .swap(fromIndex, toIndex, replacingWith):
            directChatMessages.swap(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .move(fromIndex, toIndex, replacingWith):
            directChatMessages.move(fromIndex: fromIndex, toIndex: toIndex, replacingWith: replacingWith)
        case let .composite(changes):
            for change in changes {
                performCollectionChange(change: change)
            }
        }
    }

    func directMessagesItemPressed() {
        listingViewModel?.chatWithSeller()
    }

    func directAnswersHorizontalViewDidSelect(answer: QuickAnswer) {
        listingViewModel?.sendQuickAnswer(quickAnswer: answer,
                                          trackingInfo: sectionFeedChatTrackingInfo)
    }

    func openAskPhone() {
        listingViewModel?.openAskPhone()
    }

    func callSeller() {
        guard let phoneNumber = listingViewModel?.seller.value?.phone else { return }
        PhoneCallsHelper.call(phoneNumber: phoneNumber)
        if let source = sellerTrackInfo?.source, let feedPosition = sellerTrackInfo?.feedPosition {
            listingViewModel?.trackCallTapped(source: source, feedPosition: feedPosition)
        }
    }
}

extension QuickChatViewModel: ReactiveCompatible {}
extension Reactive where Base: QuickChatViewModel {
    var directMessages: Driver<CollectionChange<ChatViewMessage>> {
        return base.directChatMessages.changesObservable.asDriver(onErrorJustReturn: .composite([]))
    }
    var chatState: Driver<QuickChatViewState> { return base.chatState.asDriver() }

    fileprivate func quickAnswersViewState(listingVM: ListingViewModel) -> Driver<QuickAnswersViewState?> {
        return listingVM.cardDirectChatEnabled
            .asObservable()
            .distinctUntilChanged()
            .map {
                return $0 ? QuickAnswersViewState(quickAnswers: listingVM.quickAnswers) : nil
        }.asDriver(onErrorJustReturn: nil)
    }

    fileprivate func proChatViewState(listingVM: ListingViewModel) -> Driver<ProChatViewState?> {
        let seller = listingVM.seller.asObservable().share()
        let phoneNumber = seller.map { $0?.phone }

        let isPro = seller.map { $0?.isProfessional ?? false }.distinctUntilChanged()

        let allowsCalls: Observable<Bool>
        if PhoneCallsHelper.deviceCanCall {
            allowsCalls = Observable
                .combineLatest(isPro, phoneNumber) { isPro, phoneNumber in (phoneNumber != nil, isPro) }
                .map { (hasPhoneNumber, isPro) in hasPhoneNumber && isPro }
        } else {
            allowsCalls = .just(false)
        }
        return Observable.combineLatest(isPro, allowsCalls) { ($0, $1) }
            .map { [unowned base] in
                guard $0 else { return nil }
                let message = $1 ? R.Strings.productProfessionalCallButton : R.Strings.productProfessionalChatButton
                let icon = $1 ? R.Asset.Monetization.icPhoneCall.image : nil
                let action = $1 ? base.callSeller : base.openAskPhone
                return ProChatViewState(message: message, icon: icon, action: action)
        }.asDriver(onErrorJustReturn: nil)
    }
}
