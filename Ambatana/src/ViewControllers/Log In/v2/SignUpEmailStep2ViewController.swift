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

final class SignUpEmailStep2ViewController: KeyboardViewController {
    fileprivate let viewModel: SignUpEmailStep2ViewModel
    fileprivate let appearance: LoginAppearance
    fileprivate let backgroundImage: UIImage?
    fileprivate let deviceFamily: DeviceFamily

    fileprivate let backgroundImageView = UIImageView()
    fileprivate let scrollView = UIScrollView()
    fileprivate let headerGradientView = UIView()
    fileprivate let headerGradientLayer = CAGradientLayer.gradientWithColor(UIColor.white,
                                                                            alphas: [1, 0], locations: [0, 1])
    fileprivate let contentView = UIView()
    fileprivate let fullNameButton = UIButton()
    fileprivate let fullNameImageView = UIImageView()
    fileprivate let fullNameTextField = LGTextField()

    fileprivate let signUpButton = UIButton()
    fileprivate let footerButton = UIButton()

    fileprivate let signUpButtonVisible = Variable<Bool>(true)

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

        setupNavigationBar()
        setupUI()
        setupLayout()
        setupRx()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        signUpPressed()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return !string.hasEmojis()
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

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.image = backgroundImage
        view.addSubview(backgroundImageView)

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

        let textfieldTextColor = UIColor.blackText
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = UIColor.blackTextHighAlpha

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

        fullNameTextField.keyboardType = .emailAddress
        fullNameTextField.autocapitalizationType = .none
        fullNameTextField.autocorrectionType = .no
        fullNameTextField.returnKeyType = .next
        fullNameTextField.textColor = textfieldTextColor
        fullNameTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailStep2NameFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        fullNameTextField.clearButtonOffset = 0
        fullNameTextField.delegate = self
        contentView.addSubview(fullNameTextField)

        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.setStyle(.primary(fontSize: .medium))
        signUpButton.setTitle(LGLocalizedString.signUpEmailStep2SignUpButton, for: .normal)
        contentView.addSubview(signUpButton)

        // TODO: !!!
//        let footerString = (LGLocalizedString.signUpEmailStep1Footer as NSString)
//        let footerAttrString = NSMutableAttributedString(string: LGLocalizedString.signUpEmailStep1Footer)
//
//        let footerStringRange = NSRange(location: 0, length: footerString.length)
//        let signUpKwRange = footerString.range(of: LGLocalizedString.signUpEmailStep1FooterLogInKw)
//
//        if signUpKwRange.location != NSNotFound {
//            let prefix = footerString.substring(to: signUpKwRange.location)
//            let prefixRange = footerString.range(of: prefix)
//            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: appearance.footerMainTextColor,
//                                          range: prefixRange)
//
//            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.primaryColor,
//                                          range: signUpKwRange)
//        } else {
//            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: appearance.footerMainTextColor,
//                                          range: footerStringRange)
//        }

        footerButton.translatesAutoresizingMaskIntoConstraints = false
        footerButton.setTitleColor(UIColor.darkGrayText, for: .normal)
//        footerButton.setAttributedTitle(footerAttrString, for: .normal)
        footerButton.titleLabel?.numberOfLines = 2
        footerButton.contentHorizontalAlignment = .center
        view.addSubview(footerButton)
    }

    func setupLayout() {
        backgroundImageView.layout(with: view).fill()

        scrollView.layout(with: topLayoutGuide).vertically()
        scrollView.layout(with: bottomLayoutGuide).vertically(invert: true)
        scrollView.layout(with: view).leading().trailing()

        headerGradientView.layout(with: topLayoutGuide).vertically()
        headerGradientView.layout(with: view).leading().trailing()
        headerGradientView.layout().height(20)

        contentView.layout(with: scrollView).top().leading().proportionalWidth()

        fullNameButton.layout(with: contentView).top(by: 30).leading(by: 15).trailing(by: -15)
        fullNameButton.layout().height(50)
        fullNameImageView.layout().width(20)
        fullNameImageView.layout(with: fullNameButton).top().bottom().leading(by: 15)
        fullNameTextField.layout(with: fullNameButton).top().bottom().leading(by: 30).trailing(by: -8)

        signUpButton.layout(with: fullNameTextField).vertically(by: 20)
        signUpButton.layout(with: contentView).leading(by: 15).trailing(by: -15).bottom(by: 15)
        signUpButton.layout().height(50)

        if deviceFamily.isWiderOrEqualThan(.iPhone6) {
            footerButton.layout(with: keyboardView).bottom(to: .top)
        } else {
            footerButton.layout(with: view).bottom()
        }
        footerButton.layout(with: view).leading(by: 15).trailing(by: -15)
        footerButton.layout().height(55, relatedBy: .greaterThanOrEqual)
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

        // TODO: ojo

//        static let invalidEmail                     = SignUpEmailStep2FormErrors(rawValue: 1 << 0)
//        static let invalidPassword                  = SignUpEmailStep2FormErrors(rawValue: 1 << 1)
//        static let usernameContainsLetgo            = SignUpEmailStep2FormErrors(rawValue: 1 << 2)
//        static let shortUsername                    = SignUpEmailStep2FormErrors(rawValue: 1 << 3)
//        static let termsAndConditionsNotAccepted    = SignUpEmailStep2FormErrors(rawValue: 1 << 4)

//        if errors.contains(.invalidEmail) {
//            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorInvalidEmail)
//        } else if errors.contains(.shortPassword) || errors.contains(.longPassword) {
//            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword)
//        }
    }
}


// MARK: > Rx

fileprivate extension SignUpEmailStep2ViewController {
    func setupRx() {

        fullNameTextField.rx.text.bindTo(viewModel.username).addDisposableTo(disposeBag)
        viewModel.signUpEnabled.bindTo(signUpButton.rx.isEnabled).addDisposableTo(disposeBag)
        signUpButton.rx.tap.subscribeNext { [weak self] _ in self?.signUpPressed() }.addDisposableTo(disposeBag)
        footerButton.rx.tap.subscribeNext { [weak self] _ in
            // TODO: Ojo con esto!
//            self?.viewModel.openLogIn()
        }.addDisposableTo(disposeBag)

        // Next button is visible depending on current content offset & keyboard visibility
        Observable.combineLatest(scrollView.rx.contentOffset.asObservable(), keyboardChanges.asObservable()) { ($0, $1) }
            .map { [weak self] (offset, keyboardChanges) -> Bool in
                guard let strongSelf = self else { return false }
                let scrollY = offset.y
                let scrollHeight = strongSelf.scrollView.frame.height
                let scrollMaxY = scrollY + scrollHeight

                let scrollVisibleMaxY: CGFloat
                if keyboardChanges.visible {
                    scrollVisibleMaxY = scrollMaxY - keyboardChanges.height
                } else {
                    scrollVisibleMaxY = scrollMaxY
                }
                let buttonMaxY = strongSelf.signUpButton.frame.maxY
                return scrollVisibleMaxY > buttonMaxY
            }.bindTo(signUpButtonVisible).addDisposableTo(disposeBag)
    }
}
