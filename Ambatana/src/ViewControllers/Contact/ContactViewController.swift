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
    
    let messagePlaceholder = NSLocalizedString("contact_body_field_hint", comment: "")
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
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
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
//        let alert = UIAlertController(title: NSLocalizedString("contact_choose_subject_dialog_title", comment: ""), message: nil, preferredStyle: .ActionSheet)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        for i in 0 ..< viewModel.numberOfSubjects {
            let subject = viewModel.subjectNameAtIndex(i)
            alert.addAction(UIAlertAction(title: subject, style: .Default, handler: { (action) -> Void in
                // Notify the view model
                self.viewModel.selectSubjectAtIndex(i)

                // Set the focus in the message, after a delay so we allow the user to see what's going on
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.messageField.becomeFirstResponder()
                }
            }))
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - ContactModelViewDelegate
    
    func viewModel(viewModel: ContactViewModel, updateSendButtonEnabledState enabled: Bool) {
        sendButton.enabled = enabled
        sendBarButton.enabled = enabled
    }
    
    func viewModel(viewModel: ContactViewModel, didFailValidationWithError error: ContactSendServiceError) {
        let message: String
        switch (error) {
        case .Network:
            message = NSLocalizedString("contact_send_error_generic", comment: "")
        case .Internal:
            message = NSLocalizedString("contact_send_error_generic", comment: "")
        case .InvalidEmail:
            message = NSLocalizedString("contact_send_error_invalid_email", comment: "")
        }
        self.showAutoFadingOutMessageAlert(message)
    }
    
    func viewModel(viewModel: ContactViewModel, didSelectSubjectWithName subjectyName: String) {
        subjectButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        subjectButton.setTitle(subjectyName, forState: .Normal)
    }
    
    func viewModelDidStartSendingContact(viewModel: ContactViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: ContactViewModel, didFinishSendingContactWithResult result: Result<Contact, ContactSendServiceError>) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.showAutoFadingOutMessageAlert(NSLocalizedString("contact_send_ok", comment: "")) {
                    navigationController?.popViewControllerAnimated(true)
                }
            }
            break
        case .Failure(let error):
            let message: String
            switch (error.value) {
            case .Network:
                message = NSLocalizedString("contact_send_error_generic", comment: "")
            case .Internal:
                message = NSLocalizedString("contact_send_error_generic", comment: "")
            case .InvalidEmail:
                message = NSLocalizedString("contact_send_error_invalid_email", comment: "")
            }
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion: completion)
        
    }
    
    // MARK: - TextViewDelegate
    
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
        
        let text = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        viewModel.message = text
        
        return true
    }
    
    // MARK: - TextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if let tag = TextFieldTag(rawValue: textField.tag) {
            switch (tag) {
            case .Email:
                viewModel.email = text
            case .Message:
                break
            }
        }
        
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextTag = tag + 1
        
        if let tag = TextFieldTag(rawValue: textField.tag) {
            switch (tag) {
            case .Email:
                subjectButtonPressed(nil)
                return false
            case .Message:
                break
            }
        }
        return true
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {
        emailField.placeholder = NSLocalizedString("contact_email_field_hint", comment: "")
        emailField.tag = TextFieldTag.Email.rawValue
        emailField.text = viewModel.email

        subjectButton.setTitle(NSLocalizedString("contact_subject_field_hint", comment: ""), forState: .Normal)
        subjectButton.setBackgroundImage(subjectButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        
        messageField.text = messagePlaceholder
        messageField.textColor = messagePlaceholderColor
        messageField.tag = TextFieldTag.Message.rawValue

        sendButton.setTitle(NSLocalizedString("contact_send_button", comment: ""), forState: UIControlState.Normal)
        sendButton.setBackgroundImage(sendButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        sendButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        sendButton.layer.cornerRadius = 4
        sendButton.enabled = false
        
        
        if emailField.text.isEmpty {
            emailField.becomeFirstResponder()
        }
        
        self.setLetGoNavigationBarStyle(title: NSLocalizedString("contact_title", comment: "") ?? UIImage(named: "navbar_logo"))
        
        sendBarButton = UIBarButtonItem(title: NSLocalizedString("contact_send_button", comment: ""), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("sendBarButtonPressed"))
        sendBarButton.enabled = false
        self.navigationItem.rightBarButtonItem = sendBarButton;
    }
}