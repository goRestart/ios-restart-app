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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackText
        label.font = .passwordLessEmailTitleFont
        label.text = R.Strings.passwordlessEmailInputTitle
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .grayDisclaimerText
        label.font = .passwordLessEmailDescriptionFont
        label.text = R.Strings.passwordlessEmailInputDescription
        return label
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.font = .passwordLessEmailTextFieldFont
        textField.textColor = .blackText
        textField.tintColor = .primaryColor
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        var placeholderAttributes = [NSAttributedStringKey: Any]()
        placeholderAttributes[NSAttributedStringKey.font] = UIFont.passwordLessEmailTextFieldFont
        placeholderAttributes[NSAttributedStringKey.foregroundColor] = UIColor.grayPlaceholderText
        textField.attributedPlaceholder = NSAttributedString(string: R.Strings.passwordlessEmailInputTextfieldPlaceholder,
                                                             attributes: placeholderAttributes)
        return textField
    }()

    private let continueButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle(R.Strings.passwordlessEmailInputButton, for: .normal)
        button.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        return button
    }()

    private enum Layout {
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

    @available(*, unavailable)
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
        setupConstraints()
    }

    private func setupNavBarActions() {
        let helpButton = UIBarButtonItem(title: R.Strings.mainSignUpHelpButton,
                                         style: .plain,
                                         target: self,
                                         action: #selector(didTapHelp))
        navigationItem.rightBarButtonItem = helpButton
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
