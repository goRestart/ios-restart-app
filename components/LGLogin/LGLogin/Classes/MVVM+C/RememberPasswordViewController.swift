import LGCoreKit
import Result
import UIKit

public class RememberPasswordViewController: BaseViewController, RememberPasswordViewModelDelegate, UITextFieldDelegate {

    // Constants & enum
    private enum TextFieldTag: Int {
        case email = 1000
    }

    private struct Layout {
        static let instructionsTopMargin: CGFloat = 80
        static let emailButtonHeight: CGFloat = 44
        static let textFieldLeftMargin: CGFloat = 45
        static let sendButtonHeight: CGFloat = 50
    }

    // ViewModel
    private var viewModel: RememberPasswordViewModel

    private let darkAppereanceBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        return view
    }()

    private let visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return view
    }()

    private let kenBurnsView: KenBurnsView = {
        let kenburns = KenBurnsView()
        return kenburns
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.mediumBodyFont
        label.textColor = UIColor.grayDisclaimerText
        return label
    }()

    private let emailIconImageView = UIImageView()
    private let emailButton = LetgoButton()
    private let emailTextField = UITextField()
    private let resetPasswordButton = LetgoButton()

    // > Helper
    private let appearance: LoginAppearance


    // MARK: - Lifecycle

    public init(viewModel: RememberPasswordViewModel, appearance: LoginAppearance = .light) {
        self.viewModel = viewModel
        self.appearance = appearance

        let statusBarStyle: UIStatusBarStyle
        let navBarBackgroundStyle: NavBarBackgroundStyle
        switch appearance {
        case .dark:
            statusBarStyle = .lightContent
            navBarBackgroundStyle = .transparent(substyle: .dark)
        case .light:
            statusBarStyle = .default
            navBarBackgroundStyle = .transparent(substyle: .light)
        }
        super.init(viewModel: viewModel, nibName: nil,
                   statusBarStyle: statusBarStyle, navBarBackgroundStyle: navBarBackgroundStyle)
        self.viewModel.delegate = self
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        emailTextField.becomeFirstResponder()
        emailTextField.tintColor = UIColor.primaryColor

        // update the textfield with the e-mail from previous view
        emailTextField.text = viewModel.email
        updateViewModelText(viewModel.email, fromTextFieldTag: emailTextField.tag)

    }

    override public func viewWillFirstAppear(_ animated: Bool) {
        super.viewWillFirstAppear(animated)
        switch appearance {
        case .light:
            break
        case .dark:
            setupKenBurns()
        }
    }


    // MARK: - Actions

    @objc func resetPasswordButtonPressed(_ sender: AnyObject) {
        viewModel.resetPassword()
    }


    // MARK: - RememberPasswordViewModelDelegate

    func viewModel(_ viewModel: RememberPasswordViewModel, updateSendButtonEnabledState enabled: Bool) {
        resetPasswordButton.isEnabled = enabled
    }


    // MARK: - UITextFieldDelegate

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .email:
                iconImageView = emailIconImageView
            }
            iconImageView.isHighlighted = true
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .email:
                iconImageView = emailIconImageView
            }
            iconImageView.isHighlighted = false
        }
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        updateViewModelText("", fromTextFieldTag: textField.tag)
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextView = view.viewWithTag(tag + 1)
        if let actualNextView = nextView {
            actualNextView.becomeFirstResponder()
        }
        else {
            viewModel.resetPassword()
        }
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let text = (textFieldText as NSString).replacingCharacters(in: range, with: string)
            updateViewModelText(text, fromTextFieldTag: textField.tag)
        }
        return true
    }


    // MARK: - Private methods
    // MARK: > UI

    private func setupUI() {
        // Appearance
        emailButton.cornerRadius = LGUIKitConstants.mediumCornerRadius
        resetPasswordButton.setStyle(.primary(fontSize: .medium))

        // i18n
        setNavBarTitle(R.Strings.resetPasswordTitle)
        emailTextField.placeholder = R.Strings.resetPasswordEmailFieldHint
        resetPasswordButton.setTitle(R.Strings.resetPasswordSendButton, for: .normal)
        instructionsLabel.text = R.Strings.resetPasswordInstructions

        // Tags
        emailTextField.tag = TextFieldTag.email.rawValue

        resetPasswordButton.addTarget(self, action: #selector(resetPasswordButtonPressed(_:)), for: .touchUpInside)
        emailTextField.delegate = self

        switch appearance {
        case .light:
            setupLightAppearance()
        case .dark:
            setupDarkAppearance()
        }
        setupConstraints()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = containerView.frame.size
    }

    private func setupConstraints() {
        view.addSubviewsForAutoLayout([darkAppereanceBgView, scrollView])
        darkAppereanceBgView.addSubviewsForAutoLayout([kenBurnsView, visualEffectView])
        scrollView.addSubviewForAutoLayout(containerView)
        containerView.addSubviewsForAutoLayout([emailButton, emailTextField, emailIconImageView, resetPasswordButton, instructionsLabel])

        darkAppereanceBgView.layout(with: self.view).fill()
        scrollView.layout(with: self.view).fill()
        containerView.layout(with: scrollView).fill()
        kenBurnsView.layout(with: darkAppereanceBgView).fill()
        visualEffectView.layout(with: darkAppereanceBgView).fill()

        let constraints: [NSLayoutConstraint] = [
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            instructionsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Layout.instructionsTopMargin),
            instructionsLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Metrics.margin),
            instructionsLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Metrics.margin),
            emailButton.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: Metrics.bigMargin),
            emailButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Metrics.margin),
            emailButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Metrics.margin),
            emailButton.heightAnchor.constraint(equalToConstant: Layout.emailButtonHeight),
            emailTextField.topAnchor.constraint(equalTo: emailButton.topAnchor),
            emailTextField.bottomAnchor.constraint(equalTo: emailButton.bottomAnchor),
            emailTextField.leftAnchor.constraint(equalTo: emailButton.leftAnchor, constant: Layout.textFieldLeftMargin),
            emailTextField.rightAnchor.constraint(equalTo: emailButton.rightAnchor, constant: -Metrics.shortMargin),
            emailIconImageView.centerYAnchor.constraint(equalTo: emailButton.centerYAnchor),
            emailIconImageView.leftAnchor.constraint(equalTo: emailButton.leftAnchor, constant: Metrics.margin),
            resetPasswordButton.topAnchor.constraint(equalTo: emailButton.bottomAnchor, constant: Metrics.margin),
            resetPasswordButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Metrics.margin),
            resetPasswordButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Metrics.margin),
            resetPasswordButton.heightAnchor.constraint(equalToConstant: Layout.sendButtonHeight),
            resetPasswordButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupLightAppearance() {
        darkAppereanceBgView.isHidden = true

        let textfieldTextColor = UIColor.lgBlack
        let textfieldTextPlaceholderColor = UIColor.lgBlack.withAlphaComponent(0.5)
        var textfieldPlaceholderAttrs = [NSAttributedStringKey: Any]()
        textfieldPlaceholderAttrs[NSAttributedStringKey.font] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSAttributedStringKey.foregroundColor] = textfieldTextPlaceholderColor

        emailButton.setStyle(.lightField)
        emailIconImageView.image = R.Asset.IconsButtons.icEmail.image
        emailIconImageView.highlightedImage = R.Asset.IconsButtons.icEmailActive.image
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: R.Strings.signUpEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
    }

    private func setupDarkAppearance() {
        darkAppereanceBgView.isHidden = false

        let textfieldTextColor = UIColor.white
        let textfieldTextPlaceholderColor = textfieldTextColor.withAlphaComponent(0.7)
        var textfieldPlaceholderAttrs = [NSAttributedStringKey: Any]()
        textfieldPlaceholderAttrs[NSAttributedStringKey.font] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSAttributedStringKey.foregroundColor] = textfieldTextPlaceholderColor

        emailButton.setStyle(.darkField)
        emailIconImageView.image = R.Asset.IconsButtons.icEmailDark.image
        emailIconImageView.highlightedImage = R.Asset.IconsButtons.icEmailActiveDark.image
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: R.Strings.signUpEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
    }

    private func setupKenBurns() {
        view.layoutIfNeeded()
        kenBurnsView.startAnimation(with: [
            R.Asset.BackgroundsAndImages.bg1New.image,
            R.Asset.BackgroundsAndImages.bg2New.image,
            R.Asset.BackgroundsAndImages.bg3New.image,
            R.Asset.BackgroundsAndImages.bg4New.image
            ])
    }

    // MARK: > Helper

    private func updateViewModelText(_ text: String, fromTextFieldTag tag: Int) {
        if let tag = TextFieldTag(rawValue: tag) {
            switch (tag) {
            case .email:
                viewModel.email = text
            }
        }
    }
}

