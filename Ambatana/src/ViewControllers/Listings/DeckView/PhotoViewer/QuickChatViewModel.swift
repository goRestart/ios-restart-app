//
//  QuickChatViewModel.swift
//  LetGo
//
//  Created by Facundo Menzella on 30/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import LGCoreKit
import LGComponents

final class QuickChatViewModel: BaseViewModel, DirectAnswersHorizontalViewDelegate {
    var listingViewModel: ListingViewModel? {
        didSet { setupRx() }
    }

    private var disposeBag = DisposeBag()

    fileprivate let chatEnabled = Variable<Bool>(false)
    fileprivate let quickAnswers = Variable<[QuickAnswer]>([])
    let directChatMessages = CollectionVariable<ChatViewMessage>([])
    fileprivate let isInterested: Variable<Bool> = .init(false)

    private func setupRx() {
        disposeBag = DisposeBag()

        guard let listingVM = listingViewModel else { return }
        quickAnswers.value = listingVM.quickAnswers
        let bindings = [
            listingVM.cardDirectChatEnabled.asDriver(onErrorJustReturn: false).drive(chatEnabled),
            listingVM.isInterested.asDriver().drive(isInterested)
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
        listingViewModel?.sendDirectMessage(directMessage, isDefaultText: isDefaultText)
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
        listingViewModel?.sendQuickAnswer(quickAnswer: answer)
    }
}

extension QuickChatViewModel: ReactiveCompatible {}
extension Reactive where Base: QuickChatViewModel {
    var quickAnswers: Observable<[QuickAnswer]> { return base.quickAnswers.asObservable() }
    var isChatEnabled: Observable<Bool> { return base.chatEnabled.asObservable() }
    var directMessages: Observable<CollectionChange<ChatViewMessage>> { return base.directChatMessages.changesObservable }
    var isInterested: Observable<Bool> { return base.isInterested.asObservable() }
}
