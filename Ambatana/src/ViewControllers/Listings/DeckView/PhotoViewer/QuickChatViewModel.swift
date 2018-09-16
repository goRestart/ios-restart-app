import Foundation
import RxSwift
import RxCocoa
import LGCoreKit
import LGComponents

struct ProChatViewState {
    let message: String
    let icon: UIImage?
}

struct QuickAnswersViewState {
    let quickAnswers: [QuickAnswer]
}

struct QuickChatViewState {
    let quickAnswersState: QuickAnswersViewState?
    let proState: ProChatViewState?
    let isInterested: Bool
}

final class QuickChatViewModel: BaseViewModel, DirectAnswersHorizontalViewDelegate {
    var listingViewModel: ListingViewModel? {
        didSet { setupRx() }
    }
    
    var sectionFeedChatTrackingInfo: SectionedFeedChatTrackingInfo?
    private var disposeBag = DisposeBag()

    fileprivate let chatState: BehaviorRelay<QuickChatViewState?> = .init(value: nil)

    let directChatMessages = CollectionVariable<ChatViewMessage>([])

    private func setupRx() {
        disposeBag = DisposeBag()

        guard let listingVM = listingViewModel else { return }

        let isInterested = listingVM.isInterested.asObservable().distinctUntilChanged()

        let bindings = [
            Observable.combineLatest(rx.quickAnswersViewState(listingVM: listingVM),
                                     rx.proChatViewState(listingVM: listingVM),
                                     isInterested) { ($0, $1, $2) }
                .map { return QuickChatViewState(quickAnswersState: $0, proState: $1, isInterested: $2) }
                .bind { [weak self] in self?.chatState.accept($0) }
        ]
        listingVM.directChatMessages
            .changesObservable
            .subscribe(onNext: { [weak self] (change) in
            self?.performCollectionChange(change: change)
        }).disposed(by: disposeBag)

        bindings.forEach { $0.disposed(by: disposeBag) }
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

}

extension QuickChatViewModel: ReactiveCompatible {}
extension Reactive where Base: QuickChatViewModel {
    var directMessages: Observable<CollectionChange<ChatViewMessage>> { return base.directChatMessages.changesObservable }
    var chatState: Observable<QuickChatViewState> { return base.chatState.asObservable().ignoreNil() }

    fileprivate func quickAnswersViewState(listingVM: ListingViewModel) -> Observable<QuickAnswersViewState?> {
        return listingVM.cardDirectChatEnabled
            .asObservable()
            .distinctUntilChanged()
            .map {
                return $0 ? QuickAnswersViewState(quickAnswers: listingVM.quickAnswers) : nil
        }
    }

    fileprivate func proChatViewState(listingVM: ListingViewModel) -> Observable<ProChatViewState?> {
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
            .map {
                guard $0 else { return nil }
                let message = $1 ? R.Strings.productProfessionalCallButton : R.Strings.productProfessionalCallButton
                let icon = $1 ? R.Asset.Monetization.icPhoneCall.image : nil
                return ProChatViewState(message: message, icon: icon)
        }
    }
}
