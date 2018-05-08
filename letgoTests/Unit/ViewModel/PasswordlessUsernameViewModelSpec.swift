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

class PasswordlessUsernameViewModelSpec: BaseViewModelSpec {

    var openHelpCalled: Bool!
    var closeUsernameViewCalled: Bool!

    override func spec() {

        var sut: PasswordlessUsernameViewModel!
        var tracker: MockTracker!
        var myUserRepository: MockMyUserRepository!
        let disposeBag = DisposeBag()

        describe("PasswordlessEmailViewModelSpec") {
            func buildPasswordlessUsernameViewModel() {
                sut = PasswordlessUsernameViewModel(myUserRepository: myUserRepository, tracker: tracker, token: "RandomToken")
                sut.navigator = self
            }

            beforeEach {
                sut = nil
                self.openHelpCalled = false
                self.closeUsernameViewCalled = false
                tracker = MockTracker()
                myUserRepository = MockMyUserRepository.makeMock()
            }

            context("Tap continue") {
                beforeEach {
                    buildPasswordlessUsernameViewModel()
                    sut.didTapDoneWith(name: "RandomName")
                }
                it("with invalid email") {
                    expect(self.closeUsernameViewCalled).toEventually(beTrue())
                }
            }

            context("Tap Help") {
                beforeEach {
                    buildPasswordlessUsernameViewModel()
                    sut.didTapHelp()
                }
                it("with invalid email") {
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
