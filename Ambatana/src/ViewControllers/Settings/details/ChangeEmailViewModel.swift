//
//  ChangeEmailViewModel.swift
//  LetGo
//
//  Created by Nestor on 18/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import Foundation
import Result
import RxSwift

protocol ChangeEmailViewModelDelegate: BaseViewModelDelegate {}

class ChangeEmailViewModel: BaseViewModel {

    weak var delegate: ChangeEmailViewModelDelegate?
    weak var navigator: ChangeEmailNavigator?
    
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    
    let currentEmail: String
    let newEmail = Variable<String?>(nil)
    var shouldAllowToContinue: Observable<Bool> {
        return newEmail.asObservable().map { [weak self] string in
            guard let strongSelf = self else { return false }
            return strongSelf.isValidEmail(string)
        }
    }
    
    // MARK: - Lifecycle
    
    init(myUserRepository: MyUserRepository, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        currentEmail = myUserRepository.myUser?.email ?? ""
        super.init()
    }
    
    override convenience init() {
        let myUserRepository = Core.myUserRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, tracker: tracker)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
     
        trackVisit()
    }
    
    // MARK: - Navigation
    
    override func backButtonPressed() -> Bool {
        navigator?.closeChangeEmail()
        return true
    }
    
    // MARK: - Validation
    
    private func isValidEmail(_ emailAddress: String?) -> Bool {
        guard let emailAddress = emailAddress else { return false }
        return emailAddress.isEmail() && emailAddress != currentEmail
    }
    
    // MARK: - Request
    
    func updateEmail() {
        guard let emailAddress = newEmail.value else { return }
        guard isValidEmail(emailAddress) else {
            delegate?.vmShowAutoFadingMessage(LGLocalizedString.changeEmailErrorInvalidEmail, completion: nil)
            return
        }
        delegate?.vmShowLoading(LGLocalizedString.changeEmailLoading)
        myUserRepository.updateEmail(emailAddress) { [weak self] (updateResult) in
            guard let strongSelf = self else { return }
            switch (updateResult) {
            case .success:
                strongSelf.updateEmailDidSuccess(with: emailAddress)
            case .failure(let error):
                strongSelf.updateEmailDidFail(with: error)
            }
        }
    }
    
    private func updateEmailDidFail(with error: RepositoryError) {
        let message: String
        switch error {
        case .network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .forbidden(cause: .emailTaken):
            message = LGLocalizedString.changeEmailErrorAlreadyRegistered
        case .internalError, .forbidden, .tooManyRequests, .userNotVerified, .serverError, .notFound, .unauthorized:
            message = LGLocalizedString.commonErrorGenericBody
        }
        delegate?.vmHideLoading(message, afterMessageCompletion: nil)
    }
    
    private func updateEmailDidSuccess(with address: String) {
        trackEditEmailComplete()
        delegate?.vmHideLoading(LGLocalizedString.changeEmailSendOk(address), afterMessageCompletion: { [weak self] in
            self?.navigator?.closeChangeEmail()
        })
    }
    
    // MARK: Tracking
    
    private func trackVisit() {
        let userId = myUserRepository.myUser?.objectId ?? ""
        let event = TrackerEvent.profileEditEmailStart(withUserId: userId)
        tracker.trackEvent(event)
    }
    
    private func trackEditEmailComplete() {
        let userId = myUserRepository.myUser?.objectId ?? ""
        let event = TrackerEvent.profileEditEmailComplete(withUserId: userId)
        tracker.trackEvent(event)
    }
}
