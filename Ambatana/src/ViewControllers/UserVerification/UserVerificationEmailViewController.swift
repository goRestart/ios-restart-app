//
//  UserVerificationEmailViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 9/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

final class UserVerificationEmailViewController: BaseViewController {

    private let viewModel: UserVerificationEmailViewModel
    private let textField = UITextField()
    private let saveButton = LetgoButton(withStyle: .primary(fontSize: .big))
    private let disposeBag = DisposeBag()
    private let keyboardHelper = KeyboardHelper()
    private var saveButtonBottomConstraint: NSLayoutConstraint?

    struct Layout {
        static let sideMargin: CGFloat = 20
        static let saveButtonHeight: CGFloat = 50
        static let saveButtonBottomMargin: CGFloat = 15
    }

    init(viewModel: UserVerificationEmailViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviewsForAutoLayout([textField, saveButton])
        title = LGLocalizedString.profileVerificationsEmailViewTitle

        textField.tintColor = UIColor.primaryColor
        textField.font = UIFont.bigBodyFont
        textField.placeholder = LGLocalizedString.profileVerificationsEmailPlaceholder

        saveButton.setTitle(LGLocalizedString.profileVerificationsSendButton, for: .normal)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        setupConstraints()
    }

    private func setupConstraints() {
        var constraints = [
            textField.topAnchor.constraint(equalTo: safeTopAnchor, constant: Layout.sideMargin),
            textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.sideMargin),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.sideMargin),
            saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.sideMargin),
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.sideMargin),
            saveButton.heightAnchor.constraint(equalToConstant: Layout.saveButtonHeight)
        ]
        let save = saveButton.bottomAnchor.constraint(equalTo: safeBottomAnchor, constant: -Layout.saveButtonBottomMargin)
        constraints.append(save)
        NSLayoutConstraint.activate(constraints)
        saveButtonBottomConstraint = save
    }

    private func setupRx() {
        keyboardHelper
            .rx_keyboardHeight
            .asDriver()
            .skip(1) // Ignore the first call with height == 0
            .drive(onNext: { [weak self] height in
                var buttonBottomMargin = -(height + Layout.saveButtonBottomMargin)
                if #available(iOS 11.0, *) {
                    buttonBottomMargin += self?.view.safeAreaInsets.bottom ?? 0
                }
                self?.saveButtonBottomConstraint?.constant = buttonBottomMargin
                UIView.animate(withDuration: 0.2, animations: {
                    self?.view.layoutIfNeeded()
                })
            }).disposed(by: disposeBag)
    }

    @objc private func didTapSave() {
        guard let email = textField.text else { return }
        viewModel.sendVerification(with: email)
    }
}
