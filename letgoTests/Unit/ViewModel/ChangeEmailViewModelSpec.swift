//
//  ChangeEmailViewModelSpec.swift
//  LetGo
//
//  Created by Nestor on 23/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble
import Result
import RxSwift
import RxTest

class ChangeEmailViewModelSpec: QuickSpec {
    var loading: Bool = false
    var loadingMessage: String = ""
    var finishedSuccessfully: Bool = false
    
    override func spec() {
        describe("ChangeEmailViewModelSpec") {
            var sut: ChangeEmailViewModel!
            var myUserRepository: MockMyUserRepository!
            var tracker = MockTracker()
            var disposeBag: DisposeBag!
            var email: String!
            var buttonEnable: Bool!
            
            beforeEach {
                myUserRepository = MockMyUserRepository()
                tracker = MockTracker()
                sut = ChangeEmailViewModel(myUserRepository: myUserRepository, tracker: tracker)
                sut.delegate = self
                
                self.loading = false
                self.loadingMessage = ""
                self.finishedSuccessfully = false
                email = nil
                buttonEnable = nil
                disposeBag = DisposeBag()
                
                sut.newEmail.asObservable().subscribeNext(onNext: { (string) in
                    email = string
                }).addDisposableTo(disposeBag)
                sut.shouldAllowToContinue.asObservable().subscribeNext(onNext: { (enabled) in
                    buttonEnable = enabled
                }).addDisposableTo(disposeBag)
            }
            
            describe("Writting an email") {
                describe("initialisation") {
                    it("button should be disabled") {
                        expect(buttonEnable).to(beFalse())
                    }
                    it("newEmail should be empty") {
                        expect(email).to(beNil())
                    }
                }
                describe("Write an invalid email") {
                    beforeEach {
                        sut.newEmail.value = "nestor.garcia@letgo"
                    }
                    it("button should be disabled") {
                        expect(buttonEnable).to(beFalse())
                    }
                }
                describe("Write an invalid email, then valid") {
                    beforeEach {
                        sut.newEmail.value = "nestor.garcia@letgo"
                        sut.newEmail.value = "nestor.garcia@letgo.com"
                    }
                    it("button should be enable") {
                        expect(buttonEnable).to(beTrue())
                    }
                }
                describe("Write an invalid email, then valid, then invalid") {
                    beforeEach {
                        sut.newEmail.value = "nestor.garcia@letgo"
                        sut.newEmail.value = "nestor.garcia@letgo.com"
                        sut.newEmail.value = "nestor.garcia@letgo"
                    }
                    it("button should be disable") {
                        expect(buttonEnable).to(beFalse())
                    }
                }
            }
            
            describe("Loading indicator") {
                describe("Should appear with a valid email") {
                    beforeEach {
                        sut.newEmail.value = "nestor.garcia@letgo.com"
                        sut.updateEmail()
                    }
                    it("Shows loading indicator") {
                        expect(self.loading).to(beTrue())
                    }
                }
                describe("Should dissapear eventually") {
                    beforeEach {
                        sut.newEmail.value = "nestor.garcia@letgo.com"
                        let repositoryError = RepositoryError(apiError: .notFound)
                        myUserRepository.myUserResult = MyUserResult(error: repositoryError)
                        sut.updateEmail()
                    }
                    it("Eventually hides indicator") {
                        expect(self.loading).toEventually(beFalse())
                    }
                }
            }
            
            describe("Loading error messages") {
                describe("emailTaken error emssage") {
                    beforeEach {
                        sut.newEmail.value = "nestor.garcia@letgo.com"
                        let error = RepositoryError(apiError: .forbidden(cause: .emailTaken))
                        myUserRepository.myUserResult = MyUserResult(error: error)
                        sut.updateEmail()
                    }
                    it("Shows the emailTaken message") {
                        expect(self.loadingMessage).toEventually(equal(LGLocalizedString.changeEmailErrorAlreadyRegistered))
                    }
                }
                describe("network error emssage") {
                    beforeEach {
                        sut.newEmail.value = "nestor.garcia@letgo.com"
                        let error = RepositoryError(apiError: .network(errorCode: 0, onBackground: false))
                        myUserRepository.myUserResult = MyUserResult(error: error)
                        sut.updateEmail()
                    }
                    it("Shows the error connection message") {
                        expect(self.loadingMessage).toEventually(equal(LGLocalizedString.commonErrorConnectionFailed))
                    }
                }
                describe("generic error emssage") {
                    beforeEach {
                        sut.newEmail.value = "nestor.garcia@letgo.com"
                        let error = RepositoryError(apiError: .notFound)
                        myUserRepository.myUserResult = MyUserResult(error: error)
                        sut.updateEmail()
                    }
                    it("Shows the generic error message") {
                        expect(self.loadingMessage).toEventually(equal(LGLocalizedString.commonErrorGenericBody))
                    }
                }
            }
            
            describe("Tracking") {
                describe("View model becomes active") {
                    let event = TrackerEvent.profileEditEmailStart(withUserId: "123")
                    beforeEach {
                        sut.active = true
                    }
                    it("Tracks a visit to edit email") {
                        expect(tracker.trackedEvents.filter({ $0 == event }).count).toEventually(equal(1))
                    }
                }
                describe("Edit an email succesfully") {
                    let myUser = MockMyUser()
                    myUser.objectId = "123"
                    let event = TrackerEvent.profileEditEmailComplete(withUserId: myUser.objectId!)
                    beforeEach {
                        sut.newEmail.value = "nestor.garcia@letgo.com"
                        myUserRepository.myUserResult = MyUserResult(myUser)
                        sut.updateEmail()
                    }
                    it("tracks a edit email complete") {
                        expect(tracker.trackedEvents.filter({ $0 == event }).count).toEventually(equal(1))
                    }
                }
            }
        }
    }
}

extension ChangeEmailViewModelSpec: ChangeEmailViewModelDelegate {
    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        loading = true
        loadingMessage = message
    }
    
    func vmShowLoading(_ loadingMessage: String?) {
        loading = true
        self.loadingMessage = loadingMessage ?? ""
    }
    
    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        loading = false
        loadingMessage = finishedMessage ?? ""
    }
    
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {}
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {}
    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {}
    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {}
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {}
    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {}
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loginStyle: LoginStyle, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}
    func vmPop() {}
    func vmDismiss(_ completion: (() -> Void)?) {}
    func vmOpenInternalURL(_ url: URL) {}
}
