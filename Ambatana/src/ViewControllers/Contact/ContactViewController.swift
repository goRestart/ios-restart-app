//
//  ContactViewController.swift
//  LetGo
//
//  Created by Dídac on 16/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import Result

class ContactViewController: BaseViewController , UITextViewDelegate, UITextFieldDelegate, ContactViewModelDelegate {
    
    enum TextFieldTag: Int {
        case Email = 1000, Message
    }
    
    let messagePlaceholder = LGLocalizedString.contactBodyFieldHint
    let messagePlaceholderColor = UIColor(rgb: 0xC7C7CD)
    
    @IBOutlet weak var emailField : LGTextField!
    @IBOutlet weak var subjectButton: UIButton!
    @IBOutlet weak var messageField : UITextView!
    @IBOutlet weak var sendButton : UIButton!
    @IBOutlet weak var messageBackground : UIView!
    @IBOutlet weak var scrollView : UIScrollView!
    
    var sendBarButton : UIBarButtonItem!
    
    var viewModel : ContactViewModel!
    
    var lines: [CALayer]
    
    init() {
        self.viewModel = ContactViewModel()
        self.lines = []
        super.init(viewModel: viewModel, nibName: "ContactViewController")
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // if email is full message becames first responder, else email always 1st resp
        if let emailFieldText = emailField.text {
            if emailFieldText.isEmpty || !viewModel.subjectIsSelected {
                emailField.becomeFirstResponder()
            }
            else {
                messageField.becomeFirstResponder()
            }
        } else {
            emailField.becomeFirstResponder()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(emailField.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(subjectButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(messageBackground.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(messageBackground.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
        
        self.messageField.textContainerInset = UIEdgeInsetsMake(12.0, 11.0, 12.0, 11.0);
    }
    
    
    @IBAction func sendContact(sender: AnyObject) {
        viewModel.sendContact()
    }
    
    func sendBarButtonPressed() {
        viewModel.sendContact()
    }
    
    @IBAction func subjectButtonPressed(sender: AnyObject?) {
        viewModel.selectSubject()
    }
    
    // MARK: - ContactModelViewDelegate
    
    
    func viewModel(viewModel: ContactViewModel, updateSendButtonEnabledState enabled: Bool) {
        sendButton.enabled = enabled
        sendButton.alpha = enabled ? 1 : StyleHelper.disabledButtonAlpha
        sendBarButton.enabled = enabled
    }
    
    func viewModel(viewModel: ContactViewModel, didFailValidationWithError error: ContactValidationError) {
        let message: String
        switch (error) {
        case .InvalidEmail:
            message = LGLocalizedString.contactSendErrorInvalidEmail
        }
        self.showAutoFadingOutMessageAlert(message)
    }

    
    func viewModelDidStartSendingContact(viewModel: ContactViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: ContactViewModel, didFinishSendingContactWithResult result: ContactResult) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.contactSendOk) {
                    navigationController?.popViewControllerAnimated(true)
                }
            }
            break
        case .Failure(let error):
            let message: String
            switch (error) {
            case .Network, .Internal, .NotFound, .Unauthorized:
                message = LGLocalizedString.contactSendErrorGeneric
            }
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion)
        
    }
    
    func pushSubjectOptionsViewWithModel(viewModel: ContactSubjectOptionsViewModel, selectedRow: Int?) {
        let vc = ContactSubjectOptionsViewController(viewModel: viewModel, selectedRow: selectedRow)
        navigationController?.pushViewController(vc, animated: true)
    }

    
    func viewModel(viewModel: ContactViewModel, updateSubjectButtonWithText text: String) {
        subjectButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        subjectButton.setTitle(text, forState: .Normal)
    }

    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        // clear text view placeholder
        if textView.text == messagePlaceholder && textView.textColor ==  messagePlaceholderColor {
            messageField.text = nil
            messageField.textColor = UIColor.blackColor()
        }
        scrollView.setContentOffset(CGPointMake(0,textView.frame.origin.y-64), animated: true)
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = messagePlaceholder
            textView.textColor = messagePlaceholderColor
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let textViewText = textView.text {
            let text = (textViewText as NSString).stringByReplacingCharactersInRange(range, withString: text)
            viewModel.message = text
        }
        return true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let text = (textFieldText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            
            if let tag = TextFieldTag(rawValue: textField.tag) {
                switch (tag) {
                case .Email:
                    viewModel.email = text
                case .Message:
                    break
                }
            }
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        viewModel.email = ""
        return true
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {
        emailField.placeholder = LGLocalizedString.contactEmailFieldHint
        emailField.tag = TextFieldTag.Email.rawValue
        emailField.text = viewModel.email

        subjectButton.setTitle(LGLocalizedString.contactSubjectFieldHint, forState: .Normal)
        subjectButton.setBackgroundImage(subjectButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        
        messageField.text = messagePlaceholder
        messageField.textColor = messagePlaceholderColor
        messageField.tag = TextFieldTag.Message.rawValue

        sendButton.setTitle(LGLocalizedString.contactSendButton, forState: UIControlState.Normal)
        sendButton.setBackgroundImage(sendButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        sendButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        sendButton.setBackgroundImage(StyleHelper.highlightedRedButtonColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Highlighted)

        sendButton.layer.cornerRadius = 4
        sendButton.enabled = false
        sendButton.alpha = StyleHelper.disabledButtonAlpha

        self.setLetGoNavigationBarStyle(LGLocalizedString.contactTitle)
        
        sendBarButton = UIBarButtonItem(title: LGLocalizedString.contactSendButton, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("sendBarButtonPressed"))
        sendBarButton.enabled = false
        self.navigationItem.rightBarButtonItem = sendBarButton;
    }
}