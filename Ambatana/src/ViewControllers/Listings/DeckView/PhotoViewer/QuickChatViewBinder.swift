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
import RxCocoa

protocol QuickChatViewType: class {
    var rxDidBeginEditing: ControlEvent<()> { get }
    var rxDidEndEditing: ControlEvent<()> { get }
    var rxPlaceholder: Binder<String?> { get }

    var hasInitialText: Bool { get }

    var rxToSendMessage: Observable<String> { get }
    func setInitialText(_ text: String)
    func clearChatTextView()
    func updateDirectChatWith(answers: [QuickAnswer])
    func handleChatChange(_ change: CollectionChange<ChatViewMessage>)
    func showDirectMessages()
}

protocol QuickChatViewModelRx: class {
    var areAnswersDynamic: Variable<Bool> { get }
    var rxAreAnswersDynamic: Driver<Bool> { get }

    var directChatPlaceholder: Variable<String> { get }
    var rxDirectChatPlaceholder: Observable<String> { get }

    var quickAnswers: Variable<[QuickAnswer]> { get }
    var rxQuickAnswers: Observable<[QuickAnswer]> { get }

    var chatEnabled: Variable<Bool> { get }
    var rxIsChatEnabled: Observable<Bool> { get }

    var directChatMessages: CollectionVariable<ChatViewMessage> { get }
    var rxDirectMessages: Observable<CollectionChange<ChatViewMessage>> { get }

    func send(directMessage: String, isDefaultText: Bool)
    func performCollectionChange(change: CollectionChange<ChatViewMessage>)
}

final class QuickChatViewBinder {
    weak var quickChatView: QuickChatViewType?
    private var disposeBag: DisposeBag?

    func bind(to quickChatViewModel: QuickChatViewModelRx?) {
        guard let viewModel = quickChatViewModel else { return }
        disposeBag = DisposeBag()

        guard let bag = disposeBag else { return }
        guard let chatView = quickChatView else { return }

        viewModel.rxDirectChatPlaceholder.bind(to: chatView.rxPlaceholder).disposed(by:bag)

        viewModel.rxAreAnswersDynamic.filter { !$0 }.drive(onNext: { [weak chatView] (dynamic) in
            chatView?.setInitialText(LGLocalizedString.chatExpressTextFieldText)
        }).disposed(by: bag)

        chatView.rxToSendMessage.bind { [weak chatView, weak viewModel] message in
            guard let quickChatView = chatView else { return }
            viewModel?.send(directMessage: message, isDefaultText: quickChatView.hasInitialText)
            quickChatView.clearChatTextView()
        }.disposed(by: bag)

        viewModel.rxQuickAnswers.bind {  [weak chatView, weak viewModel] quickAnswers in
            guard let chatViewModel = viewModel else { return }
            chatView?.updateDirectChatWith(answers: quickAnswers)
        }.disposed(by: bag)

        viewModel.rxDirectMessages.bind { [weak chatView] change in
            if change.element() != nil {
                chatView?.showDirectMessages()
            }
            chatView?.handleChatChange(change)
        }.disposed(by: bag)
    }



}
