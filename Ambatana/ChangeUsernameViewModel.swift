//
//  ChangeUsernameViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
import Result

enum ChangeUsernameError: ErrorType {
    case UsernameTaken
    case InvalidUsername
    case Api(apiError: ApiError)
    case Internal
    
    init(repositoryError: RepositoryError) {
        switch repositoryError {
        case .Api(let apiError):
            self = .Api(apiError: apiError)
        case .Internal:
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
    
    let myUserRepository: MyUserRepository
    
    var username: String {
        didSet {
            delegate?.viewModel(self, updateSaveButtonEnabledState: enableSaveButton())
        }
    }
    
    init(myUserRepository: MyUserRepository) {
        self.myUserRepository = myUserRepository
        self.username = myUserRepository.myUser?.username ?? ""
        super.init()
    }
    
    override convenience init() {
        let myUserRepository = MyUserRepository.sharedInstance
        self.init(myUserRepository: myUserRepository)
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

            myUserRepository.updatePublicUsername(username) { [weak self] updateResult in
                guard let strongSelf = self else { return }
                
                if let _ = updateResult.value {
                    let trackerEvent = TrackerEvent.profileEditEditName()
                    TrackerProxy.sharedInstance.trackEvent(trackerEvent)
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
        return theUsername.isValidUsername() &&
            (theUsername.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != MyUserManager.sharedInstance.myUser()?.publicUsername)
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
    
}