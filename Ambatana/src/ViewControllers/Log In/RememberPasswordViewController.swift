//
//  RememberPasswordViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class RememberPasswordViewController: BaseViewController, UITextFieldDelegate {

    // Constants & enum
    enum TextFieldTag: Int {
        case Email = 1000
    }
    
    // ViewModel
    var viewModel: RememberPasswordViewModel!
    
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: RememberPasswordViewModel(), nibName: "RememberPasswordViewController")
    }
    
    required init(viewModel: RememberPasswordViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        emailTextField.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor)
        emailButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Email:
                iconImageView = emailIconImageView
            }
            iconImageView.highlighted = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Email:
                iconImageView = emailIconImageView
            }
            iconImageView.highlighted = false
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.text = ""
        updateSendButtonEnabledState()
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextView = view.viewWithTag(tag + 1)
        if let actualNextView = nextView {
            actualNextView.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        textField.text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        updateSendButtonEnabledState()
        return false
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    func setupUI() {
        // Navigation bar
        let backButton = UIBarButtonItem(image: UIImage(named: "navbar_back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popViewController")
        navigationItem.leftBarButtonItem = backButton
//        navigationController?.interactivePopGestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
        
        // Appearance
        resetPasswordButton.setBackgroundImage(resetPasswordButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        resetPasswordButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        resetPasswordButton.layer.cornerRadius = 4
        
        // i18n
        title = NSLocalizedString("reset_password_title", comment: "")
        emailTextField.placeholder = NSLocalizedString("reset_password_email_field_placeholder", comment: "")
        resetPasswordButton.setTitle(NSLocalizedString("reset_password_send_button", comment: ""), forState: .Normal)
        
        // Tags
        emailTextField.tag = TextFieldTag.Email.rawValue
    }
    
    private func updateSendButtonEnabledState() {
        resetPasswordButton.enabled = count(emailTextField.text) > 0
    }
    
    // MARK: > Navigation
    
    func popViewController() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        navigationController?.view.layer.addAnimation(transition, forKey: nil)
        navigationController?.popViewControllerAnimated(false)
    }
}
