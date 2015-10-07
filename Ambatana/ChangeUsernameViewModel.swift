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

public protocol ChangeUsernameViewModelDelegate : class {
    func viewModel(viewModel: ChangeUsernameViewModel, updateSaveButtonEnabledState enabled: Bool)
    func viewModel(viewModel: ChangeUsernameViewModel, didFailValidationWithError error: UserSaveServiceError)
    func viewModelDidStartSendingUser(viewModel: ChangeUsernameViewModel)
    func viewModel(viewModel: ChangeUsernameViewModel, didFinishSendingUserWithResult result: Result<User, UserSaveServiceError>)

}

public class ChangeUsernameViewModel: BaseViewModel {
    
    weak var delegate : ChangeUsernameViewModelDelegate?
    
    var username: String {
        didSet {
            delegate?.viewModel(self, updateSaveButtonEnabledState: enableSaveButton())
        }
    }
    
    override init() {
        username = MyUserManager.sharedInstance.myUser()?.publicUsername ?? ""
        super.init()
    }
    

    // MARK: - public methods

    
    public func saveUsername() {
        // check if username is ok (func in extension?)

        if usernameContainsLetgoString(username) {
            delegate?.viewModel(self, didFailValidationWithError:UserSaveServiceError.InvalidUsername)
        }
        else if isValidUsername(username) {
            
            delegate?.viewModelDidStartSendingUser(self)

            username = username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

            MyUserManager.sharedInstance.updateUsername(username) { [weak self] (result: Result<User, UserSaveServiceError>) in
                if let strongSelf = self {
                    if let actualDelegate = strongSelf.delegate {
                        if let user = result.value {
                            // success
                            actualDelegate.viewModel(strongSelf, didFinishSendingUserWithResult: result)
                            let trackerEvent = TrackerEvent.profileEditEditName()
                            TrackerProxy.sharedInstance.trackEvent(trackerEvent)

                        }
                        else if let someError = result.error {
                            // error
                            actualDelegate.viewModel(strongSelf, didFinishSendingUserWithResult: result)
                        }
                    }
                }
            }
        }
        else {
            delegate?.viewModel(self, didFailValidationWithError:UserSaveServiceError.InvalidUsername)
        }

    }
    
    public func isValidUsername(theUsername: String) -> Bool {
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