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
        case email = 1000
    }
    
    // ViewModel
    var viewModel: RememberPasswordViewModel


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
    
    init(source: EventParameterLoginSourceValue, email: String, appearance: LoginAppearance = .light) {
        self.viewModel = RememberPasswordViewModel(source: source, email: email)
        self.appearance = appearance

        let statusBarStyle: UIStatusBarStyle
        let navBarBackgroundStyle: NavBarBackgroundStyle
        switch appearance {
        case .dark:
            statusBarStyle = .lightContent
            navBarBackgroundStyle = .transparent(substyle: .dark)
        case .light:
            statusBarStyle = .default
            navBarBackgroundStyle = .transparent(substyle: .light)
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

    override func viewWillFirstAppear(_ animated: Bool) {
        super.viewWillFirstAppear(animated)
        switch appearance {
        case .light:
            break
        case .dark:
            setupKenBurns()
        }
    }


    // MARK: - Actions
    
    @IBAction func resetPasswordButtonPressed(_ sender: AnyObject) {
        viewModel.resetPassword()
    }
    

    // MARK: - RememberPasswordViewModelDelegate
    
    func viewModel(_ viewModel: RememberPasswordViewModel, updateSendButtonEnabledState enabled: Bool) {
        resetPasswordButton.isEnabled = enabled
    }
    
    func viewModelDidStartResettingPassword(_ viewModel: RememberPasswordViewModel) {
        showLoadingMessageAlert()
    }

    func viewModelDidFinishResetPassword(_ viewModel: RememberPasswordViewModel) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(LGLocalizedString.resetPasswordSendOk(viewModel.email)) { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    func viewModel(_ viewModel: RememberPasswordViewModel, didFailResetPassword error: String) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(error)
        }
    }


    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .email:
                iconImageView = emailIconImageView
            }
            iconImageView.isHighlighted = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .email:
                iconImageView = emailIconImageView
            }
            iconImageView.isHighlighted = false
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        updateViewModelText("", fromTextFieldTag: textField.tag)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let text = (textFieldText as NSString).replacingCharacters(in: range, with: string)
            updateViewModelText(text, fromTextFieldTag: textField.tag)
        }
        return true
    }


    // MARK: - Private methods
    // MARK: > UI
    
    private func setupUI() {
        // Appearance
        emailButton.layer.cornerRadius = LGUIKitConstants.textfieldCornerRadius
        resetPasswordButton.setStyle(.primary(fontSize: .medium))
        
        // i18n
        setNavBarTitle(LGLocalizedString.resetPasswordTitle)
        emailTextField.placeholder = LGLocalizedString.resetPasswordEmailFieldHint
        resetPasswordButton.setTitle(LGLocalizedString.resetPasswordSendButton, for: UIControlState())
        instructionsLabel.text = LGLocalizedString.resetPasswordInstructions
        
        // Tags
        emailTextField.tag = TextFieldTag.email.rawValue

        switch appearance {
        case .light:
            setupLightAppearance()
        case .dark:
            setupDarkAppearance()
        }
    }

    private func setupLightAppearance() {
        darkAppereanceBgView.isHidden = true

        let textfieldTextColor = UIColor.black
        let textfieldTextPlaceholderColor = UIColor.black.withAlphaComponent(0.5)
        var textfieldPlaceholderAttrs = [String: Any]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = textfieldTextPlaceholderColor

        emailButton.setStyle(.lightField)
        emailIconImageView.image = UIImage(named: "ic_email")
        emailIconImageView.highlightedImage = UIImage(named: "ic_email_active")
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
    }

    private func setupDarkAppearance() {
        darkAppereanceBgView.isHidden = false

        let textfieldTextColor = UIColor.white
        let textfieldTextPlaceholderColor = textfieldTextColor.withAlphaComponent(0.7)
        var textfieldPlaceholderAttrs = [String: Any]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = textfieldTextPlaceholderColor

        emailButton.setStyle(.darkField)
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
        kenBurnsView.animate(withImages: images, transitionDuration: 10, initialDelay: 0, loop: true, isLandscape: true)
    }
    
    private func updateSendButtonEnabledState() {
        if let email = emailTextField.text {
            resetPasswordButton.isEnabled = email.characters.count > 0
        } else {
            resetPasswordButton.isEnabled = false
        }
    }
    
    // MARK: > Helper
    
    private func updateViewModelText(_ text: String, fromTextFieldTag tag: Int) {
        if let tag = TextFieldTag(rawValue: tag) {
            switch (tag) {
            case .email:
                viewModel.email = text
            }
        }
    }
}
