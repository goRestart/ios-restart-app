//
//  ChangeUsernameViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

enum ChangeUsernameError: ErrorType {
    case UsernameTaken
    case InvalidUsername
    
    case Network
    case Internal
    case NotFound
    case Unauthorized
    
    init(repositoryError: RepositoryError) {
        switch repositoryError {
        case .Network:
            self = .Internal
        case .NotFound:
            self = .NotFound
        case .Unauthorized:
            self = .Unauthorized
        case .Internal, .Forbidden, .TooManyRequests, .UserNotVerified, .ServerError:
            self = .Internal
        }
    }
}

protocol ChangeUsernameViewModelDelegate : class {
    func viewModel(viewModel: ChangeUsernameViewModel, updateSaveButtonEnabledState enabled: Bool)
    func viewModel(viewModel: ChangeUsernameViewModel, didFailValidationWithError error: ChangeUsernameError)
    func viewModelDidStartSendingUser(viewModel: ChangeUsernameViewModel)
    func viewModel(viewModel: ChangeUsernameViewModel, didFinishSendingUserWithResult
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
        // check if username is ok (func in extension?)

        if usernameContainsLetgoString(username) {
            delegate?.viewModel(self, didFailValidationWithError:.UsernameTaken)
        }
        else if isValidUsername(username) {
            
            delegate?.viewModelDidStartSendingUser(self)

            username = username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

            myUserRepository.updateName(username) { [weak self] updateResult in
                guard let strongSelf = self else { return }
                
                if let _ = updateResult.value {
                    let trackerEvent = TrackerEvent.profileEditEditName()
                    strongSelf.tracker.trackEvent(trackerEvent)
                }
                
                guard let delegate = strongSelf.delegate else { return }
                
                var result = Result<MyUser, ChangeUsernameError>(error: .Internal)
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
            delegate?.viewModel(self, didFailValidationWithError:.InvalidUsername)
        }

    }
    
    func isValidUsername(theUsername: String) -> Bool {
        let trimmed = theUsername.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return 2...Constants.maxUserNameLength ~= trimmed.characters.count && trimmed != myUserRepository.myUser?.name
    }
    
    
    // MARK: - private methods
    
    private func usernameContainsLetgoString(theUsername: String) -> Bool {
        let lowerCaseUsername = theUsername.lowercaseString
        return lowerCaseUsername.rangeOfString("letgo") != nil ||
            lowerCaseUsername.rangeOfString("ietgo") != nil ||
            lowerCaseUsername.rangeOfString("letg0") != nil ||
            lowerCaseUsername.rangeOfString("ietg0") != nil ||
            lowerCaseUsername.rangeOfString("let go") != nil ||
            lowerCaseUsername.rangeOfString("iet go") != nil ||
            lowerCaseUsername.rangeOfString("let g0") != nil ||
            lowerCaseUsername.rangeOfString("iet g0") != nil
    }
    
    func enableSaveButton() -> Bool {
        return isValidUsername(username)
    }

    func userNameSaved() {
        navigator?.closeChangeUsername()
    }
}
