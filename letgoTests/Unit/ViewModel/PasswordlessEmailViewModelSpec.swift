//
//  PasswordlessEmailViewModelSpec.swift
//  letgoTests
//
//  Created by Isaac Roldan on 7/5/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import RxSwift
import RxTest
import RxCocoa

class PasswordlessEmailViewModelSpec: BaseViewModelSpec {

    var closeEditBioCalled: Bool = false
    var openHelpCalled: Bool!
    var openEmailSent: Bool!

    override func spec() {

        var sut: PasswordlessEmailViewModel!
        var tracker: MockTracker!
        var sessionManager: MockSessionManager!
        let disposeBag = DisposeBag()
        var scheduler: TestScheduler!
        var isContinueActionEnabled: TestableObserver<Bool?>!


        describe("PasswordlessEmailViewModelSpec") {
            func buildPasswordlessEmailViewModel() {
                sut = PasswordlessEmailViewModel(sessionManager: sessionManager, tracker: tracker)
                sut.isContinueActionEnabled.asObservable().bind(to: isContinueActionEnabled).disposed(by: disposeBag)
                sut.navigator = self
            }

            beforeEach {
                sut = nil
                self.openHelpCalled = false
                self.openEmailSent = false
                sessionManager = MockSessionManager()
                tracker = MockTracker()

                scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                isContinueActionEnabled = scheduler.createObserver(Bool?.self)
            }

            context("init") {
                beforeEach {
                    buildPasswordlessEmailViewModel()
                }
                it("continue button is disabled") {
                    expect(isContinueActionEnabled.eventValues).toEventually(equal([false]))
                }

            }

            context("Email did change with invalid email") {
                beforeEach {
                    buildPasswordlessEmailViewModel()
                    sut.didChange(email: "invalid@email")
                }
                it("disables the continue button") {
                    expect(isContinueActionEnabled.eventValues).toEventually(equal([false, false]))
                }
            }

            context("Email did change with valid email") {
                beforeEach {
                    buildPasswordlessEmailViewModel()
                    sut.didChange(email: "valid@email.com")
                }
                it("enables the continue button") {
                    expect(isContinueActionEnabled.eventValues).toEventually(equal([false, true]))
                }
            }

            context("Tap continue") {
                beforeEach {
                    buildPasswordlessEmailViewModel()
                    sut.didTapContinueWith(email: "valid@email.com")
                }
                it("opens email sent view") {
                    expect(self.openEmailSent).toEventually(beTrue())
                }
            }

            context("Tap Help") {
                beforeEach {
                    buildPasswordlessEmailViewModel()
                    sut.didTapHelp()
                }
                it("opens the Help view") {
                    expect(self.openHelpCalled) == true
                }
            }
        }
    }
}

extension PasswordlessEmailViewModelSpec: PasswordlessNavigator {
    func closePasswordlessEmailSent() {}

    func openHelpFromPasswordless() {
        openHelpCalled = true
    }

    func openPasswordlessEmailSentTo(email: String) {
        openEmailSent = true
    }
}
