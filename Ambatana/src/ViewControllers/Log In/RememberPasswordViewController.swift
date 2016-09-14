//
//  RememberPasswordViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import JBKenBurnsView
import LGCoreKit
import Result
import UIKit

class RememberPasswordViewController: BaseViewController, RememberPasswordViewModelDelegate, UITextFieldDelegate {

    // Constants & enum
    enum TextFieldTag: Int {
        case Email = 1000
    }
    
    // ViewModel
    var viewModel: RememberPasswordViewModel!


    @IBOutlet weak var darkAppereanceBgView: UIView!
    @IBOutlet weak var kenBurnsView: JBKenBurnsView!
    
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    @IBOutlet weak var instructionsLabel : UILabel!
    
    // > Helper
    private let appearance: LoginAppearance
    
    // MARK: - Lifecycle
    
    init(source: EventParameterLoginSourceValue, email: String, appearance: LoginAppearance = .Light) {
        self.viewModel = RememberPasswordViewModel(source: source, email: email)
        self.appearance = appearance

        let statusBarStyle: UIStatusBarStyle
        let navBarBackgroundStyle: NavBarBackgroundStyle
        switch appearance {
        case .Dark:
            statusBarStyle = .LightContent
            navBarBackgroundStyle = .Transparent(substyle: .Dark)
        case .Light:
            statusBarStyle = .Default
            navBarBackgroundStyle = .Transparent(substyle: .Light)
        }
        super.init(viewModel: viewModel, nibName: "RememberPasswordViewController",
                   statusBarStyle: statusBarStyle, navBarBackgroundStyle: navBarBackgroundStyle)
        self.viewModel.delegate = self
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        emailTextField.becomeFirstResponder()
        emailTextField.tintColor = UIColor.primaryColor
        
        // update the textfield with the e-mail from previous view
        emailTextField.text = viewModel.email
        updateViewModelText(viewModel.email, fromTextFieldTag: emailTextField.tag)
        
    }

    override func viewWillFirstAppear(animated: Bool) {
        super.viewWillFirstAppear(animated)
        switch appearance {
        case .Light:
            break
        case .Dark:
            setupKenBurns()
        }
    }


    // MARK: - Actions
    
    @IBAction func resetPasswordButtonPressed(sender: AnyObject) {
        viewModel.resetPassword()
    }
    

    // MARK: - RememberPasswordViewModelDelegate
    
    func viewModel(viewModel: RememberPasswordViewModel, updateSendButtonEnabledState enabled: Bool) {
        resetPasswordButton.enabled = enabled
    }
    
    func viewModelDidStartResettingPassword(viewModel: RememberPasswordViewModel) {
        showLoadingMessageAlert()
    }

    func viewModelDidFinishResetPassword(viewModel: RememberPasswordViewModel) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(LGLocalizedString.resetPasswordSendOk(viewModel.email)) { [weak self] in
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    func viewModel(viewModel: RememberPasswordViewModel, didFailResetPassword error: String) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(error)
        }
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
        updateViewModelText("", fromTextFieldTag: textField.tag)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextView = view.viewWithTag(tag + 1)
        if let actualNextView = nextView {
            actualNextView.becomeFirstResponder()
        }
        else {
            viewModel.resetPassword()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let text = (textFieldText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            updateViewModelText(text, fromTextFieldTag: textField.tag)
        }
        return true
    }


    // MARK: - Private methods
    // MARK: > UI
    
    private func setupUI() {
        // Appearance
        emailButton.layer.cornerRadius = 10
        resetPasswordButton.setStyle(.Primary(fontSize: .Medium))
        
        // i18n
        setNavBarTitle(LGLocalizedString.resetPasswordTitle)
        emailTextField.placeholder = LGLocalizedString.resetPasswordEmailFieldHint
        resetPasswordButton.setTitle(LGLocalizedString.resetPasswordSendButton, forState: .Normal)
        instructionsLabel.text = LGLocalizedString.resetPasswordInstructions
        
        // Tags
        emailTextField.tag = TextFieldTag.Email.rawValue

        switch appearance {
        case .Light:
            setupLightAppearance()
        case .Dark:
            setupDarkAppearance()
        }
    }

    private func setupLightAppearance() {
        darkAppereanceBgView.hidden = true

        let textfieldTextColor = UIColor.black
        let textfieldTextPlaceholderColor = UIColor.black.colorWithAlphaComponent(0.5)
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFontOfSize(17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = textfieldTextPlaceholderColor

        emailButton.setStyle(.LightField)
        emailIconImageView.image = UIImage(named: "ic_email")
        emailIconImageView.highlightedImage = UIImage(named: "ic_email_active")
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
    }

    private func setupDarkAppearance() {
        darkAppereanceBgView.hidden = false

        let buttonBgColor = UIColor.white.colorWithAlphaComponent(0.3)
        let textfieldTextColor = UIColor.white
        let textfieldTextPlaceholderColor = textfieldTextColor.colorWithAlphaComponent(0.7)
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFontOfSize(17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = textfieldTextPlaceholderColor

        emailButton.setStyle(.DarkField)
        emailIconImageView.image = UIImage(named: "ic_email_dark")
        emailIconImageView.highlightedImage = UIImage(named: "ic_email_active_dark")
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
    }

    func setupKenBurns() {
        let images: [UIImage] = [
            UIImage(named: "bg_1_new"),
            UIImage(named: "bg_2_new"),
            UIImage(named: "bg_3_new"),
            UIImage(named: "bg_4_new")
            ].flatMap { return $0}
        view.layoutIfNeeded()
        kenBurnsView.animateWithImages(images, transitionDuration: 10, initialDelay: 0, loop: true, isLandscape: true)
    }
    
    private func updateSendButtonEnabledState() {
        if let email = emailTextField.text {
            resetPasswordButton.enabled = email.characters.count > 0
        } else {
            resetPasswordButton.enabled = false
        }
    }
    
    // MARK: > Helper
    
    private func updateViewModelText(text: String, fromTextFieldTag tag: Int) {
        if let tag = TextFieldTag(rawValue: tag) {
            switch (tag) {
            case .Email:
                viewModel.email = text
            }
        }
    }
}
