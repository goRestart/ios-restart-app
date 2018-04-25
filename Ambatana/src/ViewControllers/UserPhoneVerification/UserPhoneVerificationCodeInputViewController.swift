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

    private var timer: Timer?
    private let timerDuration = 2.0
    private let fullscreenMessageView = FullScreenMessageView()

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

    deinit {
        timer?.invalidate()
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewWillDisappear()
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
        setupCodeInformationButtonUI()
        setupFullscreenMessageViewUI()
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
        codeTextField.delegate = self
    }

    private func setupCodeInformationLabelUI() {
        codeInformationLabel.text = "You can request another code if you don't recieve it within 0:50" // FIXME: localize
        codeInformationLabel.font = .smsVerificationInputCodeInformation
        codeInformationLabel.textColor = .grayText
        codeInformationLabel.numberOfLines = 0
        codeInformationLabel.textAlignment = .center
    }

    private func setupCodeInformationButtonUI() {
        codeInformationButton.setTitle("No verification code received?", for: .normal) // FIXME: localize this
        codeInformationButton.setTitleColor(.primaryColor, for: .normal)
        codeInformationButton.titleLabel?.font = .smsVerificationInputCodeInformation
        codeInformationButton.addTarget(self, action: #selector(didTapOnCodeNotReceived), for: .touchUpInside)
        codeInformationButton.isHidden = true
    }

    private func setupFullscreenMessageViewUI() {
        navigationController?.view.addSubviewForAutoLayout(fullscreenMessageView)
        fullscreenMessageView.iconColor = .primaryColor
        fullscreenMessageView.isHidden = true
        fullscreenMessageView.alpha = 0
    }

    private func setupConstraints() {
        var constraints = [
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
            codeInformationButton.topAnchor.constraint(equalTo: codeInformationLabel.topAnchor),
            codeInformationButton.leftAnchor.constraint(equalTo: codeInformationLabel.leftAnchor),
            codeInformationButton.rightAnchor.constraint(equalTo: codeInformationLabel.rightAnchor)
        ]

        if let navView = navigationController?.view {
            constraints += [
                fullscreenMessageView.topAnchor.constraint(equalTo: navView.topAnchor),
                fullscreenMessageView.leftAnchor.constraint(equalTo: navView.leftAnchor),
                fullscreenMessageView.rightAnchor.constraint(equalTo: navView.rightAnchor),
                fullscreenMessageView.bottomAnchor.constraint(equalTo: navView.bottomAnchor)
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func setupRx() {
        viewModel
            .showResendCodeOption
            .asDriver()
            .drive(onNext: { [weak self] showOption in
                self?.codeInformationLabel.isHidden = showOption
                self?.codeInformationButton.isHidden = !showOption
            })
            .disposed(by: disposeBag)

        viewModel
            .validationState
            .asDriver()
            .drive(onNext: { [weak self] state in
                switch state {
                case .validating:
                    self?.showValidationLoading()
                case .success:
                    self?.showValidationFinishedWith(success: true)
                case .failure:
                    self?.showValidationFinishedWith(success: false)
                case .none:
                    break
                }
            })
            .disposed(by: disposeBag)
    }

    @objc private func didTapOnCodeNotReceived() {
        // FIXME: implement this
    }

    private func showValidationLoading() {
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.fullscreenMessageView.isHidden = false
            self?.fullscreenMessageView.alpha = 1
        }

        fullscreenMessageView.startAnimatingWith(message: "Validating code...") // FIXME: localize it
    }

    private func showValidationFinishedWith(success: Bool) {
        let message = success ? "Phone number verified!" : "The verification code you entered is incorrect."
        fullscreenMessageView.stopAnimatingWith(message: message, success: success) // FIXME: localize it

        timer = Timer.scheduledTimer(timeInterval: timerDuration,
                                     target: self,
                                     selector: #selector(didFinishValidationMessageTimer(timer:)),
                                     userInfo: ["success": success],
                                     repeats: false)
    }

    @objc private func didFinishValidationMessageTimer(timer: Timer) {
        guard let userInfo = timer.userInfo as? [String: Any],
            let success = userInfo["success"] as? Bool else { return }

        timer.invalidate()
        if success {
            viewModel.didFinishVerification()
        } else {
            codeTextField.clearText()
            codeTextField.becomeFirstResponder()
        }

        UIView.animate(withDuration: 0.5,
                       animations: { [weak self] in
                        self?.fullscreenMessageView.alpha = 0
        }) { [weak self] _ in
            self?.fullscreenMessageView.isHidden = true
            if success {
                self?.fullscreenMessageView.removeFromSuperview()
            }
        }
    }
}

extension UserPhoneVerificationCodeInputViewController: VerificationCodeTextFieldDelegate {
    func didEndEditingWith(code: String) {
        viewModel.validate(code: code)
    }
}

private class FullScreenMessageView: UIView {

    private let icon = LoadingIndicator(frame: CGRect(x: 0, y: 0, width: Layout.iconSize, height: Layout.iconSize))
    private let label = UILabel()

    var iconColor: UIColor = .primaryColor {
        didSet { icon.color = iconColor }
    }

    private struct Layout {
        static let verticalMargin: CGFloat = 10
        static let horizontalMargin: CGFloat = 20
        static let iconSize: CGFloat = 80
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewsForAutoLayout([icon, label])
        backgroundColor = .white

        label.font = .smsVerificationInputBigText
        label.textColor = .blackText
        label.numberOfLines = 0
        label.textAlignment = .center

        setupConstraints()
    }

    private func setupConstraints() {
        let constraints = [
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -Layout.verticalMargin),
            icon.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            icon.heightAnchor.constraint(equalTo: icon.widthAnchor),
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.horizontalMargin),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.horizontalMargin),
            label.topAnchor.constraint(equalTo: centerYAnchor, constant: Layout.verticalMargin)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func startAnimatingWith(message: String) {
        label.text = message
        icon.startAnimating()
    }

    func stopAnimatingWith(message: String, success: Bool) {
        label.text = message
        icon.stopAnimating(correctState: success)
    }
}
