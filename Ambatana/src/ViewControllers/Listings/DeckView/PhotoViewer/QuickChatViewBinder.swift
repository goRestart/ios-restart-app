//
//  QuickChatViewBinder.swift
//  LetGo
//
//  Created by Facundo Menzella on 01/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

protocol QuickChatViewType: class {
    var rx_chatTextView: Reactive<ChatTextView> { get }

    func setInitialText(_ text: String)
    func updateDirectChatWith(answers: [[QuickAnswer]], isDynamic: Bool)
    func handleChatChange(_ change: CollectionChange<ChatViewMessage>)
}

protocol QuickChatViewModelRx: class {
    var areAnswersDynamic: Bool { get }
    var rx_directChatPlaceholder: Observable<String> { get }
    var rx_quickAnswers: Observable<[[QuickAnswer]]> { get }
    var isChatEnabled: Observable<Bool> { get }
    var rx_directMessages: Observable<CollectionChange<ChatViewMessage>> { get }
}

final class QuickChatViewBinder {
    weak var quickChatView: QuickChatViewType?
    private var disposeBag: DisposeBag?

    func bind(to viewModel: QuickChatViewModelRx) {
        disposeBag = DisposeBag()

        guard let bag = disposeBag else { return }
        guard let chatView = quickChatView else { return }

        viewModel.rx_directChatPlaceholder
            .bindTo(chatView.rx_chatTextView.placeholder)
        .addDisposableTo(bag)

        if viewModel.areAnswersDynamic {
            chatView.setInitialText(LGLocalizedString.chatExpressTextFieldText)
        }

        viewModel.rx_quickAnswers.bindNext { [weak chatView] quickAnswers in
            chatView?.updateDirectChatWith(answers: quickAnswers, isDynamic: viewModel.areAnswersDynamic)
        }.addDisposableTo(bag)

        viewModel.rx_directMessages.bindNext { change in
            self.quickChatView?.handleChatChange(change)
        }.addDisposableTo(bag)
    }

}
