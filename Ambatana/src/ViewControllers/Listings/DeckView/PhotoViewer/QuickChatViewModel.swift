//
//  QuickChatViewModel.swift
//  LetGo
//
//  Created by Facundo Menzella on 30/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import LGCoreKit

final class QuickChatViewModel: QuickChatViewModelRx, DirectAnswersHorizontalViewDelegate {

    var listingViewModel: ListingViewModel?

    var areAnswersDynamic: Bool { return true } // TODO: ABIOS 3107

    var rx_directChatPlaceholder: Observable<String> { return directChatPlaceholder.asObservable() }
    var rx_quickAnswers: Observable<[[QuickAnswer]]> { return quickAnswers.asObservable() }

    var rx_isChatEnabled: Observable<Bool> { return chatEnabled.asObservable() } // TODO: A
    var rx_directMessages: Observable<CollectionChange<ChatViewMessage>> { return directChatMessages.changesObservable }

    let chatEnabled = Variable<Bool>(false)
    let quickAnswers = Variable<[[QuickAnswer]]>([[]])
    var directChatPlaceholder = Variable<String>("")
    let directChatMessages = CollectionVariable<ChatViewMessage>([])

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

    func directAnswersHorizontalViewDidSelect(answer: QuickAnswer, index: Int) {
        listingViewModel?.sendQuickAnswer(quickAnswer: answer)
    }
}
