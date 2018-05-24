//
//  PasswordlessEmailViewController.swift
//  LetGo
//
//  Created by Sergi Gracia on 27/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import LGComponents

final class PasswordlessEmailViewController: BaseViewController {

    private let viewModel: PasswordlessEmailViewModel
    private let disposeBag = DisposeBag()

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let emailTextField = UITextField()
    private let continueButton = LetgoButton(withStyle: .primary(fontSize: .big))

    struct Layout {
        static let viewMargin: CGFloat = 16
        static let buttonHeight: CGFloat = 50
        static let verticalTopMargin: CGFloat = 40
        static let textFieldHorizontalMargin: CGFloat = 20
        static let continueButtonDisabledOpacity: CGFloat = 0.27
    }

    init(viewModel: PasswordlessEmailViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
        setupAccessibilityIds()
    }
    
    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviewsForAutoLayout([titleLabel, descriptionLabel, emailTextField, continueButton])

        setupNavBarActions()
        setupTitleLabelUI()
        setupDescriptionLabelUI()
        setupEmailTextFieldUI()
        setupContinueButtonUI()
        setupConstraints()
    }

    private func setupNavBarActions() {
        let helpButton = UIBarButtonItem(title: R.Strings.mainSignUpHelpButton,
                                         style: .plain,
                                         target: self,
                                         action: #selector(didTapHelp))
        navigationItem.rightBarButtonItem = helpButton
    }

    private func setupTitleLabelUI() {
        titleLabel.textColor = .blackText
        titleLabel.font = .passwordLessEmailTitleFont
        titleLabel.text = R.Strings.passwordlessEmailInputTitle
    }

    private func setupDescriptionLabelUI() {
        descriptionLabel.textColor = .grayDisclaimerText
        descriptionLabel.font = .passwordLessEmailDescriptionFont
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = R.Strings.passwordlessEmailInputDescription
    }

    private func setupEmailTextFieldUI() {
        emailTextField.font = .passwordLessEmailTextFieldFont
        emailTextField.textColor = .blackText
        emailTextField.tintColor = .primaryColor
        emailTextField.autocapitalizationType = .none
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        var placeholderAttributes = [NSAttributedStringKey: Any]()
        placeholderAttributes[NSAttributedStringKey.font] = UIFont.passwordLessEmailTextFieldFont
        placeholderAttributes[NSAttributedStringKey.foregroundColor] = UIColor.grayPlaceholderText
        emailTextField.attributedPlaceholder = NSAttributedString(string: R.Strings.passwordlessEmailInputTextfieldPlaceholder,
                                                                  attributes: placeholderAttributes)
    }

    private func setupContinueButtonUI() {
        continueButton.setTitle(R.Strings.passwordlessEmailInputButton, for: .normal)
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    }

    private func setupConstraints() {
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: safeTopAnchor, constant: Layout.viewMargin),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.viewMargin),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.viewMargin),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.viewMargin),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.viewMargin),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.viewMargin),
            emailTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Layout.verticalTopMargin),
            emailTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.textFieldHorizontalMargin),
            emailTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.textFieldHorizontalMargin),
            continueButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: Layout.verticalTopMargin),
            continueButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.viewMargin),
            continueButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.viewMargin),
            continueButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupRx() {
        viewModel
            .isContinueActionEnabled
            .asDriver()
            .drive(onNext: { [weak self] isEnabled in
                self?.continueButton.alpha = isEnabled ? 1 : Layout.continueButtonDisabledOpacity
                self?.continueButton.isUserInteractionEnabled = isEnabled
            })
            .disposed(by: disposeBag)
    }

    private func setupAccessibilityIds() {
        titleLabel.set(accessibilityId: .passwordlessEmailTitleLabel)
        descriptionLabel.set(accessibilityId: .passwordlessEmailDescriptionLabel)
        emailTextField.set(accessibilityId: .passwordlessEmailTextField)
        continueButton.set(accessibilityId: .passwordlessEmailContinueButton)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.didChange(email: textField.text)
    }

    @objc private func didTapContinue() {
        guard let email = emailTextField.text else { return }
        viewModel.didTapContinueWith(email: email)
    }

    @objc private func didTapHelp() {
        viewModel.didTapHelp()
    }
}
