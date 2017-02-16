//
//  SignUpEmailStep2ViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class SignUpEmailStep2ViewController: KeyboardViewController, SignUpEmailStep2ViewModelDelegate {
    fileprivate let viewModel: SignUpEmailStep2ViewModel
    fileprivate let appearance: LoginAppearance
    fileprivate let backgroundImage: UIImage?
    fileprivate let deviceFamily: DeviceFamily

    fileprivate let backgroundImageView = UIImageView()
    fileprivate let backgroundEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    fileprivate let scrollView = UIScrollView()
    fileprivate let headerGradientView = UIView()
    fileprivate let headerGradientLayer = CAGradientLayer.gradientWithColor(UIColor.white,
                                                                            alphas: [1, 0], locations: [0, 1])
    fileprivate let contentView = UIView()
    fileprivate let headerLabel = UILabel()
    fileprivate let fullNameButton = UIButton()
    fileprivate let fullNameImageView = UIImageView()
    fileprivate let fullNameTextField = LGTextField()
    fileprivate let termsTextView = UITextView()
    fileprivate let termsSwitch = UISwitch()
    fileprivate let newsletterLabel = UILabel()
    fileprivate let newsletterSwitch = UISwitch()
    fileprivate let signUpButton = UIButton()

    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(viewModel: SignUpEmailStep2ViewModel, appearance: LoginAppearance, backgroundImage: UIImage?) {
        self.init(viewModel: viewModel, appearance: appearance, backgroundImage: backgroundImage,
                  deviceFamily: DeviceFamily.current)
    }

    init(viewModel: SignUpEmailStep2ViewModel, appearance: LoginAppearance, backgroundImage: UIImage?,
         deviceFamily: DeviceFamily) {
        self.viewModel = viewModel
        self.appearance = appearance
        self.backgroundImage = backgroundImage
        self.deviceFamily = deviceFamily
        super.init(viewModel: viewModel, nibName: nil,
                   statusBarStyle: appearance.statusBarStyle,
                   navBarBackgroundStyle: appearance.navBarBackgroundStyle)

        viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupAccessibilityIds()
        setupLayout()
        setupRx()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateUI()
    }
}


// MARK: - UITextFieldDelegate

extension SignUpEmailStep2ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        defer {
            scrollView.bounces = true  // Enable scroll bouncing so the keyboard is easy to dismiss on drag
        }

        fullNameImageView.isHighlighted = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        defer {
            scrollView.bounces = false  // Disable scroll bouncing when no editing
        }

        fullNameImageView.isHighlighted = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if signUpButton.isEnabled {
            signUpPressed()
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return !string.hasEmojis()
    }
}


// MARK: - UITextViewDelegate

extension SignUpEmailStep2ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        openInternalUrl(url)
        return false
    }
}


// MARK: - Private
// MARK: > UI


fileprivate extension SignUpEmailStep2ViewController {
    func setupNavigationBar() {
        title = LGLocalizedString.signUpEmailStep2Title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LGLocalizedString.signUpEmailStep2HelpButton, style: .plain,
                                                            target: self, action: #selector(openHelp))
    }

    func setupUI() {
        view.backgroundColor = UIColor.white

        if appearance.hasBackgroundImage {
            backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
            backgroundImageView.image = backgroundImage
            view.addSubview(backgroundImageView)

            backgroundEffectView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(backgroundEffectView)
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)

        headerGradientView.translatesAutoresizingMaskIntoConstraints = false
        headerGradientView.backgroundColor = UIColor.clear
        headerGradientView.isOpaque = true
        headerGradientView.layer.addSublayer(headerGradientLayer)
        headerGradientView.layer.sublayers?.removeAll()
        headerGradientView.layer.insertSublayer(headerGradientLayer, at: 0)
        headerGradientView.isHidden = appearance.headerGradientIsHidden
        view.addSubview(headerGradientView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textColor = appearance.labelTextColor
        headerLabel.text = LGLocalizedString.signUpEmailStep2Header(viewModel.email)
        headerLabel.numberOfLines = 0
        contentView.addSubview(headerLabel)

        let textfieldTextColor = appearance.textFieldTextColor
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = appearance.textFieldPlaceholderColor

        fullNameButton.translatesAutoresizingMaskIntoConstraints = false
        fullNameButton.setStyle(appearance.textFieldButtonStyle)
        fullNameButton.addTarget(self, action: #selector(makeFullNameFirstResponder), for: .touchUpInside)
        contentView.addSubview(fullNameButton)

        fullNameImageView.translatesAutoresizingMaskIntoConstraints = false
        fullNameImageView.image = appearance.usernameIcon(highlighted: false)
        fullNameImageView.highlightedImage = appearance.usernameIcon(highlighted: true)
        fullNameImageView.contentMode = .center
        contentView.addSubview(fullNameImageView)

        fullNameTextField.translatesAutoresizingMaskIntoConstraints = false
        fullNameTextField.text = viewModel.username.value
        fullNameTextField.keyboardType = .default
        fullNameTextField.autocapitalizationType = .none
        fullNameTextField.autocorrectionType = .no
        fullNameTextField.returnKeyType = .next
        fullNameTextField.textColor = textfieldTextColor
        fullNameTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailStep2NameFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        fullNameTextField.clearButtonMode = .whileEditing
        fullNameTextField.clearButtonOffset = 0
        fullNameTextField.delegate = self
        contentView.addSubview(fullNameTextField)

        if viewModel.termsAndConditionsAcceptRequired {
            termsTextView.translatesAutoresizingMaskIntoConstraints = false
            termsTextView.font = UIFont.systemFont(size: 15)
            termsTextView.backgroundColor = UIColor.clear
            termsTextView.tintColor = appearance.textViewTintColor
            let termsText = LGLocalizedString.signUpEmailStep2TermsConditions
            if let termsURL = viewModel.termsAndConditionsURL, let privacyURL = viewModel.privacyURL {
                let linkColor = UIColor.grayText
                let links = [LGLocalizedString.signUpEmailStep2TermsConditionsTermsKw: termsURL,
                             LGLocalizedString.signUpEmailStep2TermsConditionsPrivacyKw: privacyURL]
                let attrTermsText = termsText.attributedHyperlinkedStringWithURLDict(links, textColor: linkColor)
                attrTermsText.addAttribute(NSFontAttributeName, value: UIFont.mediumBodyFont,
                                           range: NSMakeRange(0, attrTermsText.length))
                termsTextView.attributedText = attrTermsText
            } else {
                termsTextView.text = LGLocalizedString.signUpTermsConditions
            }
            termsTextView.isScrollEnabled = false   // makes textview also to calculate full intrinsec content size
            termsTextView.isEditable = false
            termsTextView.dataDetectorTypes = .link
            termsTextView.delegate = self
            contentView.addSubview(termsTextView)

            termsSwitch.translatesAutoresizingMaskIntoConstraints = false
            termsSwitch.isOn = viewModel.termsAndConditionsAccepted.value
            contentView.addSubview(termsSwitch)
        }

        if viewModel.newsLetterAcceptRequired {
            newsletterLabel.translatesAutoresizingMaskIntoConstraints = false
            newsletterLabel.font = UIFont.systemFont(size: 15)
            newsletterLabel.textColor = UIColor.grayText
            newsletterLabel.text = LGLocalizedString.signUpEmailStep2Newsletter
            newsletterLabel.numberOfLines = 0
            contentView.addSubview(newsletterLabel)

            newsletterSwitch.translatesAutoresizingMaskIntoConstraints = false
            newsletterSwitch.isOn = viewModel.newsLetterAccepted.value
            contentView.addSubview(newsletterSwitch)
        }

        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.setStyle(.primary(fontSize: .medium))
        signUpButton.setTitle(LGLocalizedString.signUpEmailStep2SignUpButton, for: .normal)
        contentView.addSubview(signUpButton)
    }

    func setupAccessibilityIds() {
        scrollView.accessibilityId = .signUpEmailStep2ScrollView
        headerLabel.accessibilityId = .signUpEmailStep2HeaderLabel
        fullNameButton.accessibilityId = .signUpEmailStep2FullNameButton
        fullNameImageView.accessibilityId = .signUpEmailStep2FullNameImageView
        fullNameTextField.accessibilityId = .signUpEmailStep2FullNameTextField
        termsTextView.accessibilityId = .signUpEmailStep2TermsTextView
        termsSwitch.accessibilityId = .signUpEmailStep2TermsSwitch
        newsletterLabel.accessibilityId = .signUpEmailStep2NewsletterLabel
        newsletterSwitch.accessibilityId = .signUpEmailStep2NewsletterSwitch
        signUpButton.accessibilityId = .signUpEmailStep2SignUpButton
    }

    func setupLayout() {
        if appearance.hasBackgroundImage {
            backgroundImageView.layout(with: view).fill()
            backgroundEffectView.layout(with: view).fill()
        }

        scrollView.layout(with: topLayoutGuide).vertically()
        scrollView.layout(with: bottomLayoutGuide).vertically(invert: true)
        scrollView.layout(with: view).leading().trailing()

        headerGradientView.layout(with: topLayoutGuide).vertically()
        headerGradientView.layout(with: view).leading().trailing()
        headerGradientView.layout().height(20)

        contentView.layout(with: scrollView).top().leading().proportionalWidth()

        headerLabel.layout(with: contentView).top(by: 30).leading(by: 15).trailing(by: -15)

        fullNameButton.layout(with: headerLabel).vertically(by: 20)
        fullNameButton.layout(with: contentView).leading(by: 15).trailing(by: -15)
        fullNameButton.layout().height(50)
        fullNameImageView.layout().width(20)
        fullNameImageView.layout(with: fullNameButton).top().bottom().leading(by: 15)
        fullNameTextField.layout(with: fullNameButton).top().bottom().leading(by: 30).trailing(by: -8)

        var topView: UIView = fullNameTextField
        if viewModel.termsAndConditionsAcceptRequired {
            termsTextView.layout(with: contentView).leading(by: 10)
            termsTextView.layout(with: topView).vertically(by: 10)
            termsTextView.layout(with: termsSwitch).horizontally(by: -5)
            termsTextView.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)

            termsSwitch.layout(with: contentView).trailing(by: -17)
            termsSwitch.layout(with: termsTextView).centerY(priority: UILayoutPriorityDefaultLow)
            termsSwitch.layout(with: topView).vertically(by: 15, relatedBy: .greaterThanOrEqual)

            topView = termsTextView
        }

        if viewModel.newsLetterAcceptRequired {
            newsletterLabel.layout(with: contentView).leading(by: 15)
            newsletterLabel.layout(with: topView).vertically(by: 10)
            newsletterLabel.layout(with: newsletterSwitch).horizontally(by: -10)
            newsletterLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)

            newsletterSwitch.layout(with: contentView).trailing(by: -17)
            newsletterSwitch.layout(with: newsletterLabel).centerY(priority: UILayoutPriorityDefaultLow)
            newsletterSwitch.layout(with: topView).vertically(by: 15, relatedBy: .greaterThanOrEqual)

            topView = newsletterLabel
        }

        signUpButton.layout(with: topView).vertically(by: 20)
        signUpButton.layout(with: contentView).leading(by: 15).trailing(by: -15).bottom(by: 15)
        signUpButton.layout().height(50)
    }

    func updateUI() {
        // Update gradient frame
        headerGradientLayer.frame = headerGradientView.bounds

        // Redraw masked rounded corners & corner radius
        fullNameButton.setRoundedCorners([.allCorners], cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        signUpButton.rounded = true
    }

    dynamic func openHelp() {
        viewModel.openHelp()
    }

    dynamic func makeFullNameFirstResponder() {
        fullNameTextField.becomeFirstResponder()
    }

    func signUpPressed() {
        let errors = viewModel.signUp()
        openAlertWithFormErrors(errors: errors)
    }

    func openAlertWithFormErrors(errors: SignUpEmailStep2FormErrors) {
        guard !errors.isEmpty else { return }

        if errors.contains(.invalidEmail) {
            showAutoFadingOutMessageAlert(LGLocalizedString.signUpSendErrorInvalidEmail)
        } else if errors.contains(.invalidPassword) {
            showAutoFadingOutMessageAlert(LGLocalizedString.signUpSendErrorInvalidPasswordWithMax(Constants.passwordMinLength,
                                                                                                  Constants.passwordMaxLength))
        } else if errors.contains(.usernameContainsLetgo) {
            showAutoFadingOutMessageAlert(LGLocalizedString.signUpSendErrorGeneric)
        } else if errors.contains(.shortUsername) {
            showAutoFadingOutMessageAlert(LGLocalizedString.signUpSendErrorInvalidUsername(Constants.fullNameMinLength))
        } else if errors.contains(.termsAndConditionsNotAccepted) {
            showAutoFadingOutMessageAlert(LGLocalizedString.signUpAcceptanceError)
        }
    }
}


// MARK: > Rx

fileprivate extension SignUpEmailStep2ViewController {
    func setupRx() {
        fullNameTextField.rx.text.bindTo(viewModel.username).addDisposableTo(disposeBag)
        termsSwitch.rx.value.bindTo(viewModel.termsAndConditionsAccepted).addDisposableTo(disposeBag)
        newsletterSwitch.rx.value.bindTo(viewModel.newsLetterAccepted).addDisposableTo(disposeBag)
        viewModel.signUpEnabled.bindTo(signUpButton.rx.isEnabled).addDisposableTo(disposeBag)
        signUpButton.rx.tap.subscribeNext { [weak self] _ in
            self?.signUpPressed()
        }.addDisposableTo(disposeBag)
    }
}
