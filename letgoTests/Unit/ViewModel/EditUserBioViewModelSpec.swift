//
//  EditUserBioViewModelSpec.swift
//  letgoTests
//
//  Created by Isaac Roldan on 19/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import RxSwift
import RxTest
import RxCocoa

class EditUserBioViewModelSpec: BaseViewModelSpec {

    var closeEditBioCalled: Bool = false

    override func spec() {

        var sut: EditUserBioViewModel!
        var tracker: MockTracker!
        var myUserRepository: MockMyUserRepository!

        describe("PostingDetailsViewModelSpec") {
            func buildEditUserBioViewModel() {
                sut = EditUserBioViewModel(myUserRepository: myUserRepository,
                                           tracker: tracker)

                sut.navigator = self
            }

            beforeEach {
                sut = nil
                tracker = MockTracker()
                myUserRepository = MockMyUserRepository.makeMock()

                var myUser = MockMyUser.makeMock()
                myUser.biography = "initial Bio"
                myUserRepository.myUserVar.value = myUser
            }

            context("init") {
                
                beforeEach {
                    buildEditUserBioViewModel()
                }
                it("has a initial bio") {
                    expect(sut.userBio).toEventually(equal("initial Bio"))
                }

                context("Tap save button") {
                    beforeEach {
                        sut.saveBio(text: "new bio")
                    }
                    it("updates the user bio") {
                        expect(self.closeEditBioCalled).toEventually(beTrue())
                    }
                }
            }
        }
    }
}

extension EditUserBioViewModelSpec: EditUserBioNavigator {
    func closeEditUserBio() {
        closeEditBioCalled = true
    }
}
