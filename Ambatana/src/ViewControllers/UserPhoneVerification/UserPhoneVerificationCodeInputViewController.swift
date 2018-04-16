//
//  UserPhoneVerificationCodeInputViewController.swift
//  LetGo
//
//  Created by Sergi Gracia on 05/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

final class UserPhoneVerificationCodeInputViewController: BaseViewController {

    private let viewModel: UserPhoneVerificationCodeInputViewModel
    private let disposeBag = DisposeBag()

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let codeTextField = VerificationCodeTextField(digits: 6)
    private let codeInformationLabel = UILabel()
    private let codeInformationButton = UIButton()

    private struct Layout {
        static let contentMargin: CGFloat = 30
        static let titleTopMargin: CGFloat = 77
        static let subtitleTopMargin: CGFloat = 9
        static let codeTextFieldTopMargin: CGFloat = 36
    }

    init(viewModel: UserPhoneVerificationCodeInputViewModel) {
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
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
        codeTextField.becomeFirstResponder()
    }

    private func setupUI() {
        title = "Number Verification" // FIXME: localize

        view.backgroundColor = .white
        view.addSubviewsForAutoLayout([titleLabel, subtitleLabel, codeTextField,
                                       codeInformationLabel, codeInformationButton])

        setupTitleLabelUI()
        setupSubtitleLabelUI()
        setupCodeTextFieldUI()
        setupCodeInformationLabelUI()
        setupConstraints()
    }

    private func setupTitleLabelUI() {
        titleLabel.text = "Enter the 6-digit code" // FIXME: localize
        titleLabel.font = .smsVerificationInputDescription
        titleLabel.textColor = .blackText
        titleLabel.textAlignment = .center
    }

    private func setupSubtitleLabelUI() {
        subtitleLabel.text = "We've sent it to \(viewModel.phoneNumber)" // FIXME: localize
        subtitleLabel.font = .smsVerificationInputSmallDescription
        subtitleLabel.textColor = .darkGrayText
        subtitleLabel.textAlignment = .center
    }

    private func setupCodeTextFieldUI() {
        codeTextField.backgroundColor = .red
    }

    private func setupCodeInformationLabelUI() {
        codeInformationLabel.text = "You can request another code if you don't recieve it within 0:50" // FIXME: localize
        codeInformationLabel.font = .smsVerificationInputCodeInformation
        codeInformationLabel.textColor = .grayText
        codeInformationLabel.numberOfLines = 0
        codeInformationLabel.textAlignment = .center
    }

    private func setupConstraints() {
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: safeTopAnchor, constant: Layout.titleTopMargin),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.contentMargin),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.contentMargin),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.subtitleTopMargin),
            subtitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.contentMargin),
            subtitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.contentMargin),
            codeTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Layout.codeTextFieldTopMargin),
            codeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            codeInformationLabel.topAnchor.constraint(equalTo: codeTextField.bottomAnchor, constant: Layout.contentMargin),
            codeInformationLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.contentMargin),
            codeInformationLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.contentMargin),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupRx() {
        // FIXME: implement this
    }
}
