//
//  SignUpEmailStep2View.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

final class SignUpEmailStep2View: UIView {
    fileprivate let appearance: LoginAppearance
    fileprivate let backgroundImage: UIImage?
    fileprivate let deviceFamily: DeviceFamily
    fileprivate let termsAndConditionsAcceptRequired: Bool
    fileprivate let newsLetterAcceptRequired: Bool

    let backgroundImageView = UIImageView()
    let backgroundEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let scrollView = UIScrollView()
    let headerGradientView = UIView()
    let headerGradientLayer = CAGradientLayer.gradientWithColor(UIColor.white,
                                                                alphas: [1, 0], locations: [0, 1])
    let contentView = UIView()
    let headerLabel = UILabel()
    let fullNameButton = UIButton()
    let fullNameImageView = UIImageView()
    let fullNameTextField = LGTextField()
    let termsTextView = UITextView()
    let termsSwitch = UISwitch()
    let newsletterLabel = UILabel()
    let newsletterSwitch = UISwitch()
    let signUpButton = UIButton()
    weak var keyboardView: UIView?


    // MARK: - Lifecycle

    init(appearance: LoginAppearance,
         backgroundImage: UIImage?,
         deviceFamily: DeviceFamily,
         termsAndConditionsAcceptRequired: Bool,
         newsLetterAcceptRequired: Bool) {
        self.appearance = appearance
        self.backgroundImage = backgroundImage
        self.deviceFamily = deviceFamily
        self.termsAndConditionsAcceptRequired = termsAndConditionsAcceptRequired
        self.newsLetterAcceptRequired = newsLetterAcceptRequired
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

fileprivate extension SignUpEmailStep2View {
    func setupUI() {
        if appearance.hasBackgroundImage {
            backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
            backgroundImageView.image = backgroundImage
            addSubview(backgroundImageView)

            backgroundEffectView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(backgroundEffectView)
        }

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

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textColor = appearance.labelTextColor
        headerLabel.numberOfLines = 0
        contentView.addSubview(headerLabel)

        let textfieldTextColor = appearance.textFieldTextColor
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = appearance.textFieldPlaceholderColor

        fullNameButton.translatesAutoresizingMaskIntoConstraints = false
        fullNameButton.setStyle(appearance.textFieldButtonStyle)
        contentView.addSubview(fullNameButton)

        fullNameImageView.translatesAutoresizingMaskIntoConstraints = false
        fullNameImageView.image = appearance.usernameIcon(highlighted: false)
        fullNameImageView.highlightedImage = appearance.usernameIcon(highlighted: true)
        fullNameImageView.contentMode = .center
        contentView.addSubview(fullNameImageView)

        fullNameTextField.translatesAutoresizingMaskIntoConstraints = false
        fullNameTextField.keyboardType = .default
        fullNameTextField.autocapitalizationType = .none
        fullNameTextField.autocorrectionType = .no
        fullNameTextField.returnKeyType = .next
        fullNameTextField.textColor = textfieldTextColor
        fullNameTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailStep2NameFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        fullNameTextField.clearButtonMode = .whileEditing
        fullNameTextField.clearButtonOffset = 0
        contentView.addSubview(fullNameTextField)

        if termsAndConditionsAcceptRequired {
            termsTextView.translatesAutoresizingMaskIntoConstraints = false
            termsTextView.font = UIFont.systemFont(size: 15)
            termsTextView.backgroundColor = UIColor.clear
            termsTextView.tintColor = appearance.textViewTintColor
            termsTextView.isScrollEnabled = false   // makes textview also to calculate full intrinsec content size
            termsTextView.isEditable = false
            termsTextView.dataDetectorTypes = .link
            contentView.addSubview(termsTextView)

            termsSwitch.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(termsSwitch)
        }

        if newsLetterAcceptRequired {
            newsletterLabel.translatesAutoresizingMaskIntoConstraints = false
            newsletterLabel.font = UIFont.systemFont(size: 15)
            newsletterLabel.textColor = UIColor.grayText
            newsletterLabel.text = LGLocalizedString.signUpEmailStep2Newsletter
            newsletterLabel.numberOfLines = 0
            contentView.addSubview(newsletterLabel)

            newsletterSwitch.translatesAutoresizingMaskIntoConstraints = false
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
            backgroundImageView.layout(with: self).fill()
            backgroundEffectView.layout(with: self).fill()
        }

        scrollView.layout(with: self).below().fill()

        headerGradientView.layout(with: self).leading().trailing().top()
        headerGradientView.layout().height(20)

        contentView.layout(with: scrollView).top().leading().proportionalWidth()

        headerLabel.layout(with: contentView).top(by: 30).leading(by: Metrics.margin).trailing(by: -Metrics.margin)

        fullNameButton.layout(with: headerLabel).below(by: 20)
        fullNameButton.layout(with: contentView).leading(by: Metrics.margin).trailing(by: -Metrics.margin)
        fullNameButton.layout().height(Metrics.textFieldHeight)
        fullNameImageView.layout().width(20)
        fullNameImageView.layout(with: fullNameButton).top().bottom().leading(by: Metrics.margin)
        fullNameTextField.layout(with: fullNameButton).top().bottom().leading(by: 30).trailing(by: -8)

        var topView: UIView = fullNameTextField
        if termsAndConditionsAcceptRequired {
            termsTextView.layout(with: contentView).leading(by: 10)
            termsTextView.layout(with: topView).below(by: 10)
            termsTextView.layout(with: termsSwitch).alignedRight(by: -5)
            termsTextView.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)

            termsSwitch.layout(with: contentView).trailing(by: -17)
            termsSwitch.layout(with: termsTextView).centerY(priority: UILayoutPriorityDefaultLow)
            termsSwitch.layout(with: topView).below(by: 15, relatedBy: .greaterThanOrEqual)

            topView = termsTextView
        }

        if newsLetterAcceptRequired {
            newsletterLabel.layout(with: contentView).leading(by: Metrics.margin)
            newsletterLabel.layout(with: topView).below(by: 10)
            newsletterLabel.layout(with: newsletterSwitch).alignedRight(by: -10)
            newsletterLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)

            newsletterSwitch.layout(with: contentView).trailing(by: -17)
            newsletterSwitch.layout(with: newsletterLabel).centerY(priority: UILayoutPriorityDefaultLow)
            newsletterSwitch.layout(with: topView).below(by: 15, relatedBy: .greaterThanOrEqual)

            topView = newsletterLabel
        }

        signUpButton.layout(with: topView).below(by: 20)
        signUpButton.layout(with: contentView)
            .leading(by: Metrics.margin)
            .trailing(by: -Metrics.margin)
            .bottom(by: Metrics.margin)
        signUpButton.layout().height(Metrics.buttonHeight)
    }

    func updateUI() {
        // Update gradient frame
        headerGradientLayer.frame = headerGradientView.bounds

        // Redraw masked rounded corners & corner radius
        fullNameButton.setRoundedCorners([.allCorners], cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        signUpButton.rounded = true
    }
}
