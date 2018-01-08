//
//  ChangeUsernameViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

enum ChangeUsernameError: Error {
    case usernameTaken
    case invalidUsername
    
    case network
    case internalError
    case notFound
    case unauthorized
    
    init(repositoryError: RepositoryError) {
        switch repositoryError {
        case .network:
            self = .internalError
        case .notFound:
            self = .notFound
        case .unauthorized:
            self = .unauthorized
        case .internalError, .forbidden, .tooManyRequests, .userNotVerified, .serverError, .wsChatError:
            self = .internalError
        }
    }
}

protocol ChangeUsernameViewModelDelegate : class {
    func viewModel(_ viewModel: ChangeUsernameViewModel, updateSaveButtonEnabledState enabled: Bool)
    func viewModel(_ viewModel: ChangeUsernameViewModel, didFailValidationWithError error: ChangeUsernameError)
    func viewModelDidStartSendingUser(_ viewModel: ChangeUsernameViewModel)
    func viewModel(_ viewModel: ChangeUsernameViewModel, didFinishSendingUserWithResult
        result: Result<MyUser, ChangeUsernameError>)

}

class ChangeUsernameViewModel: BaseViewModel {
    
    weak var delegate : ChangeUsernameViewModelDelegate?
    weak var navigator: ChangeUsernameNavigator?
    
    let myUserRepository: MyUserRepository

    let tracker: Tracker
    
    var username: String {
        didSet {
            delegate?.viewModel(self, updateSaveButtonEnabledState: enableSaveButton())
        }
    }
    
    init(myUserRepository: MyUserRepository, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        self.username = myUserRepository.myUser?.shortName ?? ""
        super.init()
    }
    
    override convenience init() {
        let myUserRepository = Core.myUserRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, tracker: tracker)
    }
    
    override func backButtonPressed() -> Bool {
        navigator?.closeChangeUsername()
        return true
    }
    

    // MARK: - public methods

    
    func saveUsername() {
        // check if username is ok
        let trimmedUsername = username.trim
        if trimmedUsername.containsLetgo() {
            delegate?.viewModel(self, didFailValidationWithError:.usernameTaken)
        } else if isValidUsername(trimmedUsername) {
            delegate?.viewModelDidStartSendingUser(self)

            myUserRepository.updateName(trimmedUsername) { [weak self] updateResult in
                guard let strongSelf = self else { return }
                
                if let _ = updateResult.value {
                    let trackerEvent = TrackerEvent.profileEditEditName()
                    strongSelf.tracker.trackEvent(trackerEvent)
                }
                
                guard let delegate = strongSelf.delegate else { return }
                
                var result = Result<MyUser, ChangeUsernameError>(error: .internalError)
                if let value = updateResult.value {
                    result = Result<MyUser, ChangeUsernameError>(value: value)
                } else if let repositoryError = updateResult.error {
                    let error = ChangeUsernameError(repositoryError: repositoryError)
                    result = Result<MyUser, ChangeUsernameError>(error: error)
                }
                delegate.viewModel(strongSelf, didFinishSendingUserWithResult: result)
            }
        }
        else {
            delegate?.viewModel(self, didFailValidationWithError:.invalidUsername)
        }

    }
    
    func isValidUsername(_ theUsername: String) -> Bool {
        let trimmed = theUsername.trimmingCharacters(in: CharacterSet.whitespaces)
        return 2...Constants.maxUserNameLength ~= trimmed.count && trimmed != myUserRepository.myUser?.name
    }
    
    
    // MARK: - private methods
    
    func enableSaveButton() -> Bool {
        return isValidUsername(username)
    }

    func userNameSaved() {
        navigator?.closeChangeUsername()
    }
}
