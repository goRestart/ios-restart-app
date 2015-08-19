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
    func viewModel(viewModel: ContactViewModel, updateSubjectButtonWithText text: String)
    func pushSubjectOptionsViewWithModel(viewModel: ContactSubjectOptionsViewModel, selectedRow: Int?)
}

public class ContactViewModel: BaseViewModel, ContactSubjectSelectionReceiverDelegate {
    
    // Services & delegate
    private let contactService : ContactSendService
    public weak var delegate: ContactViewModelDelegate?

    private var subjectOptionsViewModel : ContactSubjectOptionsViewModel!
    
    // Input
    public var email: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: enableSendButton())
        }
    }
    public var message: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: enableSendButton())
        }
    }
    
    // Output
    public var numberOfSubjects: Int {
        get {
            return ContactSubject.allValues.count
        }
    }
    
    public var subject: ContactSubject? {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: enableSendButton())
        }
    }
    
    // MARK: - Lifecycle
    
    override init() {
        email = MyUserManager.sharedInstance.myUser()?.email ?? ""
        subject = nil
        message = ""
        contactService = PAContactSendService()
        super.init()
    }
    
    // MARK: - Public methods
    
    public func selectSubject() {
    
        if subjectOptionsViewModel == nil {
            subjectOptionsViewModel = ContactSubjectOptionsViewModel()
        }
        subjectOptionsViewModel.selectionReceiverDelegate = self
        
        if let alreadySelectedSubject = subject {
            subjectOptionsViewModel.subject = alreadySelectedSubject
        }
        
        delegate?.pushSubjectOptionsViewWithModel(subjectOptionsViewModel, selectedRow: subject?.hashValue)
    }
    
    public func sendContact() {
        
        if self.email.isEmail() {
            
            var contact : Contact
            contact = PAContact()
            contact.email = email
            contact.title = subject?.name ?? ""
            contact.message = self.message + systemInfoForMessage() + " " + self.email

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
    
    // MARK: Private methods
    
    private func enableSendButton() -> Bool {
        
        return !email.isEmpty && subject != nil && (!message.isEmpty && message != NSLocalizedString("contact_body_field_hint", comment: ""))
    }
    
    // Add app, OS and device info to contact messages
    private func systemInfoForMessage() -> String {
        
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
    
    
    // MARK: - ContactSubjectSelectionReceiverDelegate
    
    public func viewModel(viewModel: ContactSubjectOptionsViewModel, selectedSubject: ContactSubject) {
        subject = selectedSubject
        delegate?.viewModel(self, updateSubjectButtonWithText: selectedSubject.name)
        
    }
}