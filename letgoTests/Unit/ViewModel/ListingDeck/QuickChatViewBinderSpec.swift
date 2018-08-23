//
//  QuickChatViewBinderSpec.swift
//  LetGo
//
//  Created by Facundo Menzella on 01/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import RxCocoa
import LGCoreKit
import Quick
import Nimble

final class QuickChatViewBinderSpec: QuickSpec {

    override func spec() {
        var sut: QuickChatViewBinder!
        var quickChatView: MockQuickChatView!
        var quickChatVM: MockQuickChatViewModelRx!

        describe("QuickChatView is visible") {
            beforeEach {
                quickChatView = MockQuickChatView()
                quickChatVM = MockQuickChatViewModelRx()

                sut = QuickChatViewBinder()
                sut.quickChatView = quickChatView
                sut.bind(to: quickChatVM)
            }

            afterEach {
                quickChatView.resetVariables()
                quickChatVM.resetVariables()
            }

            context("new message sent") {
                beforeEach {
                    quickChatView.sendRandomMessage()
                }
                it("send is called") {
                    expect(quickChatVM.sendCalled).toEventually(equal(1))
                }
            }

            context("chatViewMessages changes") {
                beforeEach {
                    let message = ChatViewMessage(objectId: nil,
                                                  talkerId: String.makeRandom(),
                                                  sentAt: nil,
                                                  receivedAt: nil,
                                                  readAt: nil,
                                                  type: .text(text: String.makeRandom()),
                                                  status: nil,
                                                  warningStatus: .normal,
                                                  userAvatarData: nil)
                    quickChatVM.directChatMessages.insert(message, atIndex: 0)
                }
                it("handleChatChange is called") {
                    expect(quickChatView.handleChatChangeCalled).toEventually(equal(1))
                }
            }

            context("we dealloc the view") {
                beforeEach {
                    quickChatView = MockQuickChatView()
                }
                it("and the binder's view reference dies too (so weak)") {
                    expect(sut.quickChatView).to(beNil())
                }
            }
        }
    }
}

private class MockQuickChatView: QuickChatViewType {
    var rxDidBeginEditing: ControlEvent<()> { return textField.rx.controlEvent(.editingDidBegin) }
    var rxDidEndEditing: ControlEvent<()> { return textField.rx.controlEvent(.editingDidEnd) }
    var rxPlaceholder: Binder<String?> { return chatTextView.rx.placeholder }

    var chatTextView = ChatTextView()
    var textField = UITextField()
    var hasInitialText: Bool = false

    var rxToSendMessage: Observable<String> { return textView.rx.send }
    var rxChatTextView: Reactive<ChatTextView> { return textView.rx }

    var showDirectMessagesCalled: Int = 0
    var clearChatTextViewCalled: Int = 0
    var setInitialTextCalled: Int = 0
    var updateDirectChatCalled: Int = 0
    var handleChatChangeCalled: Int = 0

    private var textView = ChatTextView()

    func showDirectMessages() {
        showDirectMessagesCalled += 1
    }

    func sendRandomMessage() {
        let textfield = UITextField()
        textfield.text = String.makeRandom()
        _ = textView.textFieldShouldReturn(textfield)
    }

    func resetVariables() {
        setInitialTextCalled = 0
        updateDirectChatCalled = 0
        handleChatChangeCalled = 0
        clearChatTextViewCalled = 0
    }
    func clearChatTextView() {
        clearChatTextViewCalled += 1
    }
    func setInitialText(_ text: String) {
        setInitialTextCalled += 1
    }
    func updateDirectChatWith(answers: [QuickAnswer]) {
        updateDirectChatCalled += 1
    }
    func handleChatChange(_ change: CollectionChange<ChatViewMessage>) {
        handleChatChangeCalled += 1
    }
}

fileprivate extension QuickChatViewType {
    func resetVariables() {}
}

fileprivate extension QuickChatViewModelRx {
    func resetVariables() {}
}

final class MockQuickChatViewModelRx: QuickChatViewModelRx {
    func performCollectionChange(change: CollectionChange<ChatViewMessage>) {
        performCollectionChangeCalled += 1
    }

    func send(directMessage: String, isDefaultText: Bool) {
        sendCalled += 1
    }

    func resetVariables() {
        sendCalled = 0
        performCollectionChangeCalled = 0
    }

    var sendCalled: Int = 0
    var performCollectionChangeCalled: Int = 0

    var rxDirectChatPlaceholder: Observable<String> { return directChatPlaceholder.asObservable() }
    var rxQuickAnswers: Observable<[QuickAnswer]> { return quickAnswers.asObservable() }
    var rxIsChatEnabled: Observable<Bool> { return chatEnabled.asObservable() }
    var rxDirectMessages: Observable<CollectionChange<ChatViewMessage>> { return directChatMessages.changesObservable }

    let directChatPlaceholder = Variable<String>("")
    let quickAnswers = Variable<[QuickAnswer]>([])
    let chatEnabled = Variable<Bool>(false)
    let directChatMessages = CollectionVariable<ChatViewMessage>([])
}
