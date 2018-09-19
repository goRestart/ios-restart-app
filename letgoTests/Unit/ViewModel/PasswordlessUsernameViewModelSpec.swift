//
//  PasswordlessConfirmUsernameViewModelSpec.swift
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

final class PasswordlessUsernameViewModelSpec: BaseViewModelSpec {

    var openHelpCalled: Bool!
    var closeUsernameViewCalled: Bool!

    override func spec() {

        var sut: PasswordlessUsernameViewModel!
        var tracker: MockTracker!
        var sessionManager: MockSessionManager!
        let disposeBag = DisposeBag()

        describe("PasswordlessEmailViewModelSpec") {
            func buildPasswordlessUsernameViewModel() {
                sut = PasswordlessUsernameViewModel(sessionManager: sessionManager,
                                                    tracker: tracker,
                                                    token: "RandomToken")
                sut.navigator = self
            }

            beforeEach {
                sut = nil
                self.openHelpCalled = false
                self.closeUsernameViewCalled = false
                tracker = MockTracker()
                sessionManager = MockSessionManager()
            }

            context("Tap continue") {
                beforeEach {
                    buildPasswordlessUsernameViewModel()
                    sut.didTapDoneWith(name: "RandomName")
                }
                it("closes the view") {
                    expect(self.closeUsernameViewCalled).toEventually(beTrue())
                }
            }

            context("Tap Help") {
                beforeEach {
                    buildPasswordlessUsernameViewModel()
                    sut.didTapHelp()
                }
                it("opens the Help view") {
                    expect(self.openHelpCalled) == true
                }
            }
        }
    }
}

extension PasswordlessUsernameViewModelSpec: PasswordlessUsernameNavigator {
    func closePasswordlessConfirmUsername() {
        closeUsernameViewCalled = true
    }

    func openHelp() {
        openHelpCalled = true
    }
}
