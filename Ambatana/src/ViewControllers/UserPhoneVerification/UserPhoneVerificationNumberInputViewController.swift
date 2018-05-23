//
//  SMSPhoneInputViewController.swift
//  LetGo
//
//  Created by Sergi Gracia on 03/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

final class UserPhoneVerificationNumberInputViewController: BaseViewController {

    private let viewModel: UserPhoneVerificationNumberInputViewModel
    private let keyboardHelper = KeyboardHelper()
    private let disposeBag = DisposeBag()

    private let descriptionLabel = UILabel()
    private let countryButton = UIButton()
    private let countryButtonArrowImage = UIImageView(image: #imageLiteral(resourceName: "ic_disclosure"))
    private let countryCodeLabel = UILabel()
    private let phoneNumberTextField = UITextField()
    private let horizontalSeparatorView = UIView()
    private let verticalSeparatorView = UIView()
    private let continueButton = LetgoButton(withStyle: .primary(fontSize: .medium))
    private var continueButtonBottomConstraint: NSLayoutConstraint?

    struct Layout {
        static let descriptionTopMargin: CGFloat = 40
        static let viewSidesMargin: CGFloat = 20
        static let countryButtonTopMargin: CGFloat = 50
        static let phoneNumberLeftMargin: CGFloat = 22
        static let horizontalLineMargin: CGFloat = 12
        static let lineThickness: CGFloat = 1
        static let verticalLineHeight: CGFloat = 56
        static let continueButtonBottomMargin: CGFloat = 15
        static let continueButtonHeight: CGFloat = 50
        static let continueButtonDisabledOpacity: CGFloat = 0.27
    }

    init(viewModel: UserPhoneVerificationNumberInputViewModel) {
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
        phoneNumberTextField.becomeFirstResponder()
    }

    private func setupUI() {
        title = LGLocalizedString.phoneVerificationNumberInputViewTitle

        view.backgroundColor = .white
        view.addSubviewsForAutoLayout([descriptionLabel, countryButton, countryButtonArrowImage,
                                       countryCodeLabel, phoneNumberTextField, continueButton,
                                       horizontalSeparatorView, verticalSeparatorView])
        setupDescriptionLabelUI()
        setupCountryButtonUI()
        setupCountryCodeLabelUI()
        setupPhoneNumberTextfieldUI()
        setupSeparatorsViewUI()
        setupContinueButtonUI()
        setupConstraints()
    }

    private func setupDescriptionLabelUI() {
        descriptionLabel.text = LGLocalizedString.phoneVerificationNumberInputViewDescription
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .smsVerificationInputDescription
        descriptionLabel.textColor = .blackText
    }

    private func setupCountryButtonUI () {
        countryButton.setTitleColor(.blackText, for: .normal)
        countryButton.contentHorizontalAlignment = .left
        countryButton.titleLabel?.font = .smsVerificationInputBigText
        countryButton.addTarget(self, action: #selector(didTapSelectCountry), for: .touchUpInside)
    }

    private func setupCountryCodeLabelUI () {
        countryCodeLabel.font = .smsVerificationInputBigText
        countryCodeLabel.textColor = .blackText
    }

    private func setupPhoneNumberTextfieldUI () {
        phoneNumberTextField.font = .smsVerificationInputBigText
        phoneNumberTextField.textColor = .blackText
        phoneNumberTextField.keyboardType = .numberPad
        phoneNumberTextField.tintColor = .primaryColor
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        var placeholderAttributes = [NSAttributedStringKey: Any]()
        placeholderAttributes[NSAttributedStringKey.font] = UIFont.smsVerificationInputBigText
        placeholderAttributes[NSAttributedStringKey.foregroundColor] = UIColor.grayPlaceholderText
        phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.phoneVerificationNumberInputViewTextfieldPlaceholder,
                                                                        attributes: placeholderAttributes)
    }

    private func setupSeparatorsViewUI () {
        horizontalSeparatorView.backgroundColor = .lineGray
        verticalSeparatorView.backgroundColor = .lineGray
    }

    private func setupContinueButtonUI () {
        continueButton.setTitle(LGLocalizedString.phoneVerificationNumberInputViewContinueButton, for: .normal)
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    }

    private func setupConstraints() {
        var constraints = [
            descriptionLabel.topAnchor.constraint(equalTo: safeTopAnchor, constant: Layout.descriptionTopMargin),
            descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.viewSidesMargin),
            descriptionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.viewSidesMargin),
            countryButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Layout.countryButtonTopMargin),
            countryButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.viewSidesMargin),
            countryButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.viewSidesMargin),
            countryButtonArrowImage.centerYAnchor.constraint(equalTo: countryButton.centerYAnchor),
            countryButtonArrowImage.rightAnchor.constraint(equalTo: countryButton.rightAnchor),
            countryCodeLabel.topAnchor.constraint(equalTo: horizontalSeparatorView.bottomAnchor, constant: Layout.horizontalLineMargin),
            countryCodeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.viewSidesMargin),
            phoneNumberTextField.topAnchor.constraint(equalTo: countryCodeLabel.topAnchor),
            phoneNumberTextField.leftAnchor.constraint(equalTo: countryCodeLabel.rightAnchor, constant: Layout.phoneNumberLeftMargin),
            phoneNumberTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.viewSidesMargin),
            horizontalSeparatorView.topAnchor.constraint(equalTo: countryButton.bottomAnchor, constant: Layout.horizontalLineMargin),
            horizontalSeparatorView.centerXAnchor.constraint(equalTo: countryButton.centerXAnchor),
            horizontalSeparatorView.widthAnchor.constraint(equalTo: countryButton.widthAnchor, multiplier: 1),
            horizontalSeparatorView.heightAnchor.constraint(equalToConstant: Layout.lineThickness),
            verticalSeparatorView.topAnchor.constraint(equalTo: horizontalSeparatorView.bottomAnchor),
            verticalSeparatorView.leftAnchor.constraint(equalTo: countryCodeLabel.rightAnchor, constant: 10),
            verticalSeparatorView.widthAnchor.constraint(equalToConstant: Layout.lineThickness),
            verticalSeparatorView.heightAnchor.constraint(equalToConstant: Layout.verticalLineHeight),
            continueButton.heightAnchor.constraint(equalToConstant: Layout.continueButtonHeight),
            continueButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.viewSidesMargin),
            continueButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.viewSidesMargin)
        ]

        let continueButtonConstraint = continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                              constant: -Layout.continueButtonBottomMargin)
        constraints.append(continueButtonConstraint)
        NSLayoutConstraint.activate(constraints)
        continueButtonBottomConstraint = continueButtonConstraint

        countryCodeLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func setupRx() {
        keyboardHelper
            .rx_keyboardOrigin
            .asDriver()
            .skip(1) // Ignore the first call with height == 0
            .drive(onNext: { [weak self] origin in
                guard let viewHeight = self?.view.height else { return }
                let height = viewHeight - origin
                self?.continueButtonBottomConstraint?.constant = -(height + Layout.continueButtonBottomMargin)
                UIView.animate(withDuration: 0.2, animations: {
                    self?.view.layoutIfNeeded()
                })
            }).disposed(by: disposeBag)

        viewModel
            .country
            .asDriver()
            .drive(onNext: { [weak self] country in
                guard let country = country else { return }
                self?.countryButton.setTitle(country.name, for: .normal)
                self?.countryCodeLabel.text = "+\(country.callingCode)"
            })
            .disposed(by: disposeBag)

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
        countryButton.set(accessibilityId: .phoneVerificationNumberInputCountryButton)
        countryCodeLabel.set(accessibilityId: .phoneVerificationNumberInputCountryCodeLabel)
        phoneNumberTextField.set(accessibilityId: .phoneVerificationNumberInputTextField)
        continueButton.set(accessibilityId: .phoneVerificationNumberInputContinueButton)
    }

    @objc private func didTapSelectCountry() {
        viewModel.didTapCountryButton()
    }

    @objc private func didTapContinue() {
        phoneNumberTextField.resignFirstResponder()
        guard let phoneNumber = phoneNumberTextField.text else { return }
        viewModel.didTapContinueButton(with: phoneNumber)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.didChangePhone(number: textField.text)
    }
}
