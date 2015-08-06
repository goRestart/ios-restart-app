//
//  ContactViewModel.swift
//  LetGo
//
//  Created by Dídac on 16/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import Parse
import Result
import UIDeviceUtil

public protocol ContactViewModelDelegate: class {
    func viewModel(viewModel: ContactViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModel(viewModel: ContactViewModel, didFailValidationWithError error: ContactSendServiceError)
    func viewModelDidStartSendingContact(viewModel: ContactViewModel)
    func viewModel(viewModel: ContactViewModel, didFinishSendingContactWithResult result: Result<Contact, ContactSendServiceError>)
}

public class ContactViewModel: BaseViewModel {
    
    let contactService : ContactSendService
    weak var delegate: ContactViewModelDelegate?

    var email: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: enableSendButton())
        }
    }
    var title: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: enableSendButton())
        }
    }
    var message: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: enableSendButton())
        }
    }
    
    
    override init() {
        email = MyUserManager.sharedInstance.myUser()?.email ?? ""
        title = ""
        message = ""
        self.contactService = PAContactSendService()
        super.init()
    }

    
    public func sendContact() {
        
        if self.email.isEmail() {
            
            var contact : Contact
            contact = PAContact()
            contact.email = self.email
            contact.title = self.title
            contact.message = self.message + buildMessage() + " " + self.email

            contact.user = MyUserManager.sharedInstance.myUser()
            contact.processed = NSNumber(bool: false)
            
            delegate?.viewModelDidStartSendingContact(self)
            
            self.contactService.sendContact(contact) { [weak self] (finalResult: Result<Contact, ContactSendServiceError>) in
                
                if let strongSelf = self {
                    if let actualDelegate = strongSelf.delegate {
                        if let contact = finalResult.value {
                            // success
                            actualDelegate.viewModel(strongSelf, didFinishSendingContactWithResult: finalResult)
                        }
                        else if let someError = finalResult.error {
                            // error
                            actualDelegate.viewModel(strongSelf, didFinishSendingContactWithResult: finalResult)
                            
                        }
                    }
                }
            }
        } else {
            delegate?.viewModel(self, didFailValidationWithError: .InvalidEmail)
        }
    }
    
    // MARK: private methods
    
    private func enableSendButton() -> Bool {
        
        return !email.isEmpty && !title.isEmpty && (!message.isEmpty && message != NSLocalizedString("contact_body_field_hint", comment: ""))
    }
    
    // Add app, OS and device info to contact messages
    private func buildMessage() -> String {
        
        var finalMessage = "\n\n------------\n"
        
        if let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            finalMessage = finalMessage + "App Version:  \(appVersion)\n"
        }

        if let iOSVersion = NSBundle.mainBundle().infoDictionary?["DTPlatformVersion"] as? String {
            finalMessage = finalMessage + "OS Version:  iOS \(iOSVersion)\n"
        }
        
        if let hwVersion = UIDeviceUtil.hardwareDescription() {
            finalMessage = finalMessage + "Device model: \(hwVersion)\n"
        }
        
        if let language = NSLocale.preferredLanguages()[0] as? String {
            finalMessage = finalMessage + "Language :    \(language)\n"
        }

        finalMessage = finalMessage + "------------\n\n"

        return finalMessage
    }
    
}