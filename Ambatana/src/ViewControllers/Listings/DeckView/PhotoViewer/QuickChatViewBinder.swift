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
    var rxChatTextView: Reactive<ChatTextView> { get }
    var rxToSendMessage: Observable<String> { get }
    func setInitialText(_ text: String)
    func clearChatTextView()
    func updateDirectChatWith(answers: [[QuickAnswer]], isDynamic: Bool)
    func handleChatChange(_ change: CollectionChange<ChatViewMessage>)
    func showDirectMessages()
}

protocol QuickChatViewModelRx: class {
    var areAnswersDynamic: Bool { get }
    var rxDirectChatPlaceholder: Observable<String> { get }
    var rxQuickAnswers: Observable<[[QuickAnswer]]> { get }
    var rxIsChatEnabled: Observable<Bool> { get }
    var rxDirectMessages: Observable<CollectionChange<ChatViewMessage>> { get }

    func send(directMessage: String, isDefaultText: Bool)
}

final class QuickChatViewBinder {
    weak var quickChatView: QuickChatViewType?
    private var disposeBag: DisposeBag?

    func bind(to viewModel: QuickChatViewModelRx) {
        disposeBag = DisposeBag()

        guard let bag = disposeBag else { return }
        guard let chatView = quickChatView else { return }

        viewModel.rxDirectChatPlaceholder
            .bind(to: chatView.rxChatTextView.placeholder)
        .disposed(by:bag)

        if viewModel.areAnswersDynamic {
            chatView.setInitialText(LGLocalizedString.chatExpressTextFieldText)
        }
        chatView.rxToSendMessage.bind { [weak chatView] message in
            guard let quickChatView = chatView else { return }
            viewModel.send(directMessage: message, isDefaultText: quickChatView.rxChatTextView.base.isInitialText)
            quickChatView.clearChatTextView()
        }.disposed(by: bag)

        viewModel.rxQuickAnswers.bind {  [weak chatView] quickAnswers in
            chatView?.updateDirectChatWith(answers: quickAnswers, isDynamic: viewModel.areAnswersDynamic)
        }.disposed(by: bag)

        viewModel.rxDirectMessages.bind { [weak chatView] change in
            chatView?.showDirectMessages()
            chatView?.handleChatChange(change)
        }.disposed(by: bag)
    }



}
