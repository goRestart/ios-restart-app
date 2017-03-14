//
//  SignUpEmailStep1View.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import UIKit

final class SignUpEmailStep1View: UIView {
    fileprivate let appearance: LoginAppearance

    let scrollView = UIScrollView()
    let headerGradientView = UIView()
    let headerGradientLayer = CAGradientLayer.gradientWithColor(UIColor.white,
                                                                    alphas: [1, 0], locations: [0, 1])
    let contentView = UIView()
    let emailButton = UIButton()
    let emailImageView = UIImageView()
    let emailTextField = AutocompleteField()

    let passwordButton = UIButton()
    let passwordImageView = UIImageView()
    let passwordTextField = LGTextField()
    let showPasswordButton = UIButton()
    let nextStepButton = UIButton()
    let footerButton = UIButton()
    
    fileprivate var lines: [CALayer] = []

    let nextStepButtonVisible = Variable<Bool>(true)


    // MARK: - Lifecycle

    init(appearance: LoginAppearance) {
        self.appearance = appearance
        super.init(frame: CGRect.zero)

        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        updateUI()
    }
}


// MARK: - Private methods

fileprivate extension SignUpEmailStep1View {
    func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.keyboardDismissMode = .onDrag
        addSubview(scrollView)

        headerGradientView.translatesAutoresizingMaskIntoConstraints = false
        headerGradientView.backgroundColor = UIColor.clear
        headerGradientView.isOpaque = true
        headerGradientView.layer.addSublayer(headerGradientLayer)
        headerGradientView.layer.sublayers?.removeAll()
        headerGradientView.layer.insertSublayer(headerGradientLayer, at: 0)
        headerGradientView.isHidden = appearance.headerGradientIsHidden
        addSubview(headerGradientView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        let textfieldTextColor = appearance.textFieldTextColor
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = appearance.textFieldPlaceholderColor

        emailButton.translatesAutoresizingMaskIntoConstraints = false
        emailButton.setStyle(appearance.textFieldButtonStyle)
        contentView.addSubview(emailButton)

        emailImageView.translatesAutoresizingMaskIntoConstraints = false
        emailImageView.image = appearance.emailIcon(highlighted: false)
        emailImageView.highlightedImage = appearance.emailIcon(highlighted: true)
        emailImageView.contentMode = .center
        contentView.addSubview(emailImageView)

        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.returnKeyType = .next
        emailTextField.textColor = textfieldTextColor
        emailTextField.completionColor = appearance.textFieldPlaceholderColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailStep1EmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
        emailTextField.clearButtonMode = .whileEditing
        emailTextField.clearButtonOffset = 0
        emailTextField.pixelCorrection = -1
        contentView.addSubview(emailTextField)

        passwordButton.translatesAutoresizingMaskIntoConstraints = false
        passwordButton.setStyle(appearance.textFieldButtonStyle)
        contentView.addSubview(passwordButton)

        passwordImageView.translatesAutoresizingMaskIntoConstraints = false
        passwordImageView.image = appearance.passwordIcon(highlighted: false)
        passwordImageView.highlightedImage = appearance.passwordIcon(highlighted: true)
        passwordImageView.contentMode = .center
        contentView.addSubview(passwordImageView)

        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.keyboardType = .default
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.returnKeyType = .send
        passwordTextField.textColor = textfieldTextColor
        passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailStep1PasswordFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.clearButtonOffset = 0
        contentView.addSubview(passwordTextField)

        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        showPasswordButton.setImage(appearance.showPasswordIcon(highlighted: false), for: .normal)
        showPasswordButton.setImage(appearance.showPasswordIcon(highlighted: true), for: .highlighted)
        showPasswordButton.setImage(appearance.showPasswordIcon(highlighted: true), for: .selected)
        contentView.addSubview(showPasswordButton)

        nextStepButton.translatesAutoresizingMaskIntoConstraints = false
        nextStepButton.setStyle(.primary(fontSize: .medium))
        nextStepButton.setTitle(LGLocalizedString.signUpEmailStep1ContinueButton, for: .normal)
        contentView.addSubview(nextStepButton)

        let footerString = (LGLocalizedString.signUpEmailStep1Footer as NSString)
        let footerAttrString = NSMutableAttributedString(string: LGLocalizedString.signUpEmailStep1Footer)

        let footerStringRange = NSRange(location: 0, length: footerString.length)
        let signUpKwRange = footerString.range(of: LGLocalizedString.signUpEmailStep1FooterLogInKw)

        if signUpKwRange.location != NSNotFound {
            let prefix = footerString.substring(to: signUpKwRange.location)
            let prefixRange = footerString.range(of: prefix)
            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: appearance.footerMainTextColor,
                                          range: prefixRange)

            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.primaryColor,
                                          range: signUpKwRange)
        } else {
            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: appearance.footerMainTextColor,
                                          range: footerStringRange)
        }

        footerButton.translatesAutoresizingMaskIntoConstraints = false
        footerButton.setTitleColor(UIColor.darkGrayText, for: .normal)
        footerButton.setAttributedTitle(footerAttrString, for: .normal)
        footerButton.titleLabel?.numberOfLines = 2
        footerButton.contentHorizontalAlignment = .center
        addSubview(footerButton)
    }

    func setupAccessibilityIds() {
        scrollView.accessibilityId = .signUpEmailStep1ScrollView
        emailButton.accessibilityId = .signUpEmailStep1EmailButton
        emailImageView.accessibilityId = .signUpEmailStep1EmailImageView
        emailTextField.accessibilityId = .signUpEmailStep1EmailTextField
        passwordButton.accessibilityId = .signUpEmailStep1PasswordButton
        passwordImageView.accessibilityId = .signUpEmailStep1PasswordImageView
        passwordTextField.accessibilityId = .signUpEmailStep1PasswordTextField
        showPasswordButton.accessibilityId = .signUpEmailStep1ShowPasswordButton
        nextStepButton.accessibilityId = .signUpEmailStep1NextStepButton
        footerButton.accessibilityId = .signUpEmailStep1FooterButton
    }

    func setupLayout() {
        scrollView.layout(with: self).fill()

        headerGradientView.layout(with: self).leading().trailing().top()
        headerGradientView.layout().height(20)

        contentView.layout(with: scrollView).top().leading().proportionalWidth()

        emailButton.layout(with: contentView)
            .top(by: Metrics.loginContentTop)
            .leading(by: Metrics.margin)
            .trailing(by: -Metrics.margin)
        emailButton.layout().height(Metrics.textFieldHeight)
        emailImageView.layout().width(20)
        emailImageView.layout(with: emailButton).top().bottom().leading(by: 15)
        emailTextField.layout(with: emailButton).top().bottom().leading(by: 30).trailing(by: -8)

        passwordButton.layout(with: contentView).leading(by: 15).trailing(by: -15)
        passwordButton.layout(with: emailButton).below()
        passwordButton.layout().height(Metrics.textFieldHeight)
        passwordImageView.layout().width(20)
        passwordImageView.layout(with: passwordButton).top().bottom().leading(by: 15)
        passwordTextField.layout(with: passwordButton).top().bottom().leading(by: 30)
        passwordTextField.layout(with: showPasswordButton).toRight(by: -5)
        passwordTextField.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        showPasswordButton.layout().width(30).widthProportionalToHeight()
        showPasswordButton.layout(with: passwordButton).trailing(by: -10).centerY()

        nextStepButton.layout(with: passwordTextField).below(by: 20)
        nextStepButton.layout(with: contentView)
            .leading(by: Metrics.margin)
            .trailing(by: -Metrics.margin)
            .bottom(by: Metrics.margin)
        nextStepButton.layout().height(Metrics.buttonHeight)

        footerButton.layout(with: self).leading(by: Metrics.margin).trailing(by: -Metrics.margin).bottom()
        footerButton.layout().height(Metrics.loginFooterHeight, relatedBy: .greaterThanOrEqual)
    }

    func updateUI() {
        // Update gradient frame
        headerGradientLayer.frame = headerGradientView.bounds

        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        lines.append(passwordButton.addTopBorderWithWidth(1, color: appearance.lineColor))

        // Redraw masked rounded corners & corner radius
        emailButton.setRoundedCorners([.topLeft, .topRight], cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        passwordButton.setRoundedCorners([.bottomLeft, .bottomRight], cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        nextStepButton.rounded = true
    }
}
