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
import DeviceUtil

public protocol ContactViewModelDelegate: class {
    func viewModel(viewModel: ContactViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModel(viewModel: ContactViewModel, didFailValidationWithError error: ContactSendServiceError)
    func viewModelDidStartSendingContact(viewModel: ContactViewModel)
    func viewModel(viewModel: ContactViewModel, didFinishSendingContactWithResult result: ContactSendServiceResult)
    func viewModel(viewModel: ContactViewModel, updateSubjectButtonWithText text: String)
    func pushSubjectOptionsViewWithModel(viewModel: ContactSubjectOptionsViewModel, selectedRow: Int?)
}

public class ContactViewModel: BaseViewModel, ContactSubjectSelectionReceiverDelegate {
    
    // Manager & Services
    private let myUserRepository: MyUserRepository
    private let contactService : ContactSendService
    
    // View Model
    private var subjectOptionsViewModel : ContactSubjectOptionsViewModel!
    
    // Delegate
    public weak var delegate: ContactViewModelDelegate?
    
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
    
    public var subjectIsSelected : Bool {
        return self.subject != nil
    }
    
    // MARK: - Lifecycle
    
    public required init(myUserRepository: MyUserRepository, contactService: ContactSendService) {
        self.myUserRepository = myUserRepository
        self.contactService = contactService
        self.email = myUserRepository.myUser?.email ?? ""
        self.subject = nil
        self.message = ""
        super.init()
    }
    
    public convenience override init() {
        let myUserRepository = MyUserRepository.sharedInstance
        let contactService = LGContactSendService()
        self.init(myUserRepository: myUserRepository, contactService: contactService)
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
            let contact = LGContact(email: email, title: subject?.name ?? "",
                message: self.message + systemInfoForMessage() + " " + self.email)
            
            delegate?.viewModelDidStartSendingContact(self)
            
            // Send the contact
            self.contactService.sendContact(contact, sessionToken: "") { [weak self] (finalResult: ContactSendServiceResult) in
                
                if let strongSelf = self {
                    if let actualDelegate = strongSelf.delegate {
                        if let _ = finalResult.value {
                            // success
                            actualDelegate.viewModel(strongSelf, didFinishSendingContactWithResult: finalResult)
                        }
                        else if let _ = finalResult.error {
                            // error
                            actualDelegate.viewModel(strongSelf, didFinishSendingContactWithResult: finalResult)
                            
                        }
                    }
                }
            }
            
            // Save the email if
            if shouldUpdateMyEmail() {
                myUserRepository.updateEmail(email, completion: nil)
            }
        } else {
            delegate?.viewModel(self, didFailValidationWithError: .InvalidEmail)
        }
    }
    
    // MARK: Private methods
    
    private func enableSendButton() -> Bool {
        return !email.isEmpty && subject != nil && (!message.isEmpty && message != LGLocalizedString.contactBodyFieldHint)
    }
    
    private func shouldUpdateMyEmail() -> Bool {
        // Should update the email if nil or empty
        if let myUserEmail = myUserRepository.myUser?.email {
            return myUserEmail.isEmpty
        }
        return true
    }
    
    // Add app, OS and device info to contact messages
    private func systemInfoForMessage() -> String {
        
        var finalMessage = "\n\n------------\n"
        
        if let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            finalMessage = finalMessage + "App Version:  \(appVersion)\n"
        }

        finalMessage = finalMessage + "OS Version:  iOS \(UIDevice.currentDevice().systemVersion)\n"

        if let hwVersion = DeviceUtil.hardwareDescription() {
            finalMessage = finalMessage + "Device model: \(hwVersion)\n"
        }
        
        finalMessage = finalMessage + "Language :    \(NSLocale.preferredLanguages()[0])\n"

        finalMessage = finalMessage + "------------\n\n"

        return finalMessage
    }
    
    
    // MARK: - ContactSubjectSelectionReceiverDelegate
    
    public func viewModel(viewModel: ContactSubjectOptionsViewModel, selectedSubject: ContactSubject) {
        subject = selectedSubject
        delegate?.viewModel(self, updateSubjectButtonWithText: selectedSubject.name)
        
    }
}