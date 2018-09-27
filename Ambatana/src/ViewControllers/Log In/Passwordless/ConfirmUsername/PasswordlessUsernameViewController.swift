//
//  PasswordlessUsernameViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 30/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import LGComponents

final class PasswordlessUsernameViewController: BaseViewController {

    private let viewModel: PasswordlessUsernameViewModel
    private let disposeBag = DisposeBag()
    private let keyboardHelper = KeyboardHelper()
    private let titleLabel = UILabel()
    private let usernameTextField = UITextField()
    private let doneButton = LetgoButton(withStyle: .primary(fontSize: .big))
    private var doneButtonBottomConstraint: NSLayoutConstraint?

    private enum Layout {
        static let viewMargin: CGFloat = 16
        static let buttonHeight: CGFloat = 50
        static let textFieldTopMargin: CGFloat = 25
        static let textFieldHorizontalMargin: CGFloat = 20
        static let continueButtonDisabledOpacity: CGFloat = 0.27
        static let imageWidth: CGFloat = 118
        static let imageHeight: CGFloat = 122
        static let imageRightMargin: CGFloat = 25
        static let imageTopMargin: CGFloat = 30
        static let textfieldHeight: CGFloat = 60
    }

    init(viewModel: PasswordlessUsernameViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        self.viewModel.delegate = self
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
        usernameTextField.becomeFirstResponder()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviewsForAutoLayout([titleLabel, usernameTextField, doneButton])
        setNavBarCloseButton(#selector(close))
        setupNavBarActions()
        setupTitleLabelUI()
        setupUsernameTextFieldUI()
        setupDoneButtonUI()
        setupConstraints()
    }

    private func setupNavBarActions() {
        let helpButton = UIBarButtonItem(title: R.Strings.mainSignUpHelpButton,
                                         style: .plain,
                                         target: self,
                                         action: #selector(didTapHelp))
        navigationItem.rightBarButtonItem = helpButton
    }

    @objc private func close() {
        viewModel.didTapClose()
    }

    private func setupTitleLabelUI() {
        titleLabel.textColor = .blackText
        titleLabel.font = .passwordLessUsernameTitleFont
        titleLabel.text = R.Strings.passwordlessUsernameInputTitle
        titleLabel.numberOfLines = 2
    }

    private func setupUsernameTextFieldUI() {
        usernameTextField.font = .passwordLessEmailTextFieldFont
        usernameTextField.textColor = .blackText
        usernameTextField.tintColor = .primaryColor

        var placeholderAttributes = [NSAttributedStringKey: Any]()
        placeholderAttributes[NSAttributedStringKey.font] = UIFont.passwordLessEmailTextFieldFont
        placeholderAttributes[NSAttributedStringKey.foregroundColor] = UIColor.grayPlaceholderText
        usernameTextField.attributedPlaceholder = NSAttributedString(string: R.Strings.passwordlessUsernameInputTextfieldPlaceholder,
                                                                 attributes: placeholderAttributes)
    }

    private func setupDoneButtonUI() {
        doneButton.setTitle(R.Strings.passwordlessUsernameInputDoneButton, for: .normal)
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
    }

    private func setupConstraints() {
        var constraints = [
            titleLabel.topAnchor.constraint(equalTo: safeTopAnchor, constant: Layout.viewMargin),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.viewMargin),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.viewMargin),
            usernameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.textFieldTopMargin),
            usernameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.textFieldHorizontalMargin),
            usernameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.textFieldHorizontalMargin),
            usernameTextField.heightAnchor.constraint(equalToConstant: Layout.textfieldHeight),
            doneButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.viewMargin),
            doneButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.viewMargin),
            doneButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ]
        let done = doneButton.bottomAnchor.constraint(equalTo: safeBottomAnchor, constant: -Metrics.margin)
        constraints.append(done)
        NSLayoutConstraint.activate(constraints)
        doneButtonBottomConstraint = done
    }

    private func setupRx() {
        usernameTextField
            .rx
            .text
            .map { $0?.isEmpty ?? true }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isEmpty in
                self?.doneButton.isEnabled = !isEmpty
            })
            .disposed(by: disposeBag)

        keyboardHelper
            .rx_keyboardHeight
            .asDriver()
            .skip(1) // Ignore the first call with height == 0
            .drive(onNext: { [weak self] height in
                self?.doneButtonBottomConstraint?.constant = -(height + Metrics.margin)
                UIView.animate(withDuration: 0.2, animations: {
                    self?.view.layoutIfNeeded()
                })
            }).disposed(by: disposeBag)
    }

    private func setupAccessibilityIds() {
        titleLabel.set(accessibilityId: .passwordlessUsernameTitleLabel)
        usernameTextField.set(accessibilityId: .passwordlessUsernameUsernameTextField)
        doneButton.set(accessibilityId: .passwordlessDoneButton)
    }

    @objc private func didTapDone() {
        guard let text = usernameTextField.text else { return }
        viewModel.didTapDoneWith(name: text)
    }

    @objc private func didTapHelp() {
        viewModel.didTapHelp()
    }
}
