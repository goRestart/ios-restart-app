import Foundation
import UIKit
import RxSwift
import LGComponents

final class ProfessionalDealerAskPhoneViewController: KeyboardViewController, UITextFieldDelegate {

    private let introTextMinimumHeight: CGFloat = 100
    private let introTextRightMargin: CGFloat = 46
    private let letsTalkLabelHeight: CGFloat = 21

    private let closeButton: UIButton = UIButton()
    private let notNowButton: UIButton = UIButton()
    private let introTextLabel: UILabel = UILabel()
    private let letsTalkLabel: UILabel = UILabel()
    private let phoneTextField: UITextField = UITextField()
    private let sendPhoneButton = LetgoButton(withStyle: .primary(fontSize: .medium))

    private var viewModel: ProfessionalDealerAskPhoneViewModel
    private var keyboardHelper: KeyboardHelper

    private let disposeBag = DisposeBag()


    // MARK: Lifecycle

    init(viewModel: ProfessionalDealerAskPhoneViewModel) {
        self.viewModel = viewModel
        self.keyboardHelper = KeyboardHelper()
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupRx()
        setAccessibilityIds()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneTextField.becomeFirstResponder()
    }


    // MARK: Private Methods

    private func setupUI() {
        view.backgroundColor = UIColor.lgBlack.withAlphaComponent(0.9)

        closeButton.setImage(#imageLiteral(resourceName: "ic_close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)

        notNowButton.setTitle(R.Strings.professionalDealerAskPhoneNotNowButton, for: .normal)
        notNowButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        notNowButton.setTitleColor(UIColor.lightGray, for: .normal)
        notNowButton.addTarget(self, action: #selector(notNowPressed), for: .touchUpInside)

        introTextLabel.font = UIFont.boldSystemFont(ofSize: 24)
        introTextLabel.textAlignment = .left
        introTextLabel.text = R.Strings.professionalDealerAskPhoneIntroText
        introTextLabel.textColor = UIColor.white
        introTextLabel.minimumScaleFactor = 0.3
        introTextLabel.numberOfLines = 0

        letsTalkLabel.font = UIFont.boldSystemFont(ofSize: 17)
        letsTalkLabel.textAlignment = .left
        letsTalkLabel.text = R.Strings.professionalDealerAskPhoneLetsTalkText
        letsTalkLabel.textColor = UIColor.white

        phoneTextField.font = UIFont.boldSystemFont(ofSize: 27)
        phoneTextField.attributedPlaceholder = NSAttributedString(string: R.Strings.professionalDealerAskPhoneTextfieldPlaceholder,
                                                                  attributes: [.foregroundColor : UIColor.grayDark])
        phoneTextField.textColor = UIColor.white
        phoneTextField.textAlignment = .left
        phoneTextField.tintColor = UIColor.primaryColor
        phoneTextField.keyboardType = .numberPad
        phoneTextField.delegate = self

        sendPhoneButton.frame = CGRect(x: 0, y: 0, width: 0, height: Metrics.buttonHeight)
        sendPhoneButton.setTitle(R.Strings.professionalDealerAskPhoneSendPhoneButton, for: .normal)
        sendPhoneButton.addTarget(self, action: #selector(sendPhonePressed), for: .touchUpInside)
    }

    private func setupConstraints() {

        let views: [UIView] = [closeButton, notNowButton, introTextLabel, letsTalkLabel, phoneTextField, sendPhoneButton]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: views)
        view.addSubviews(views)

        closeButton.layout().width(LGUIKitConstants.smallButtonHeight).height(LGUIKitConstants.smallButtonHeight)
        closeButton.layout(with: topLayoutGuide).top(to: .bottom)
        closeButton.layout(with: view).left(by: Metrics.margin)

        notNowButton.layout().height(LGUIKitConstants.smallButtonHeight)
        notNowButton.layout(with: topLayoutGuide).top(to: .bottom)
        notNowButton.layout(with: view).right(by: -Metrics.margin)
        notNowButton.layout(with: closeButton).left(by: Metrics.margin, relatedBy: .greaterThanOrEqual)

        introTextLabel.layout().height(introTextMinimumHeight, relatedBy: .greaterThanOrEqual)
        introTextLabel.layout(with: view).left(by: Metrics.bigMargin).right(by: -introTextRightMargin)
        introTextLabel.layout(with: closeButton).top(to: .bottom, by: Metrics.bigMargin)

        letsTalkLabel.layout().height(letsTalkLabelHeight)
        letsTalkLabel.layout(with: view).left(by: Metrics.bigMargin)
        letsTalkLabel.layout(with: introTextLabel).top(to: .bottom, by: Metrics.veryBigMargin)

        phoneTextField.layout().height(Metrics.textFieldHeight)
        phoneTextField.layout(with: view).left(by: Metrics.bigMargin).right(by: -Metrics.bigMargin)
        phoneTextField.layout(with: letsTalkLabel).top(to: .bottom, by: Metrics.bigMargin)

        sendPhoneButton.layout().height(Metrics.buttonHeight)
        sendPhoneButton.layout(with: phoneTextField).top(to: .bottom, by: Metrics.bigMargin)
        sendPhoneButton.layout(with: view).left(by: Metrics.bigMargin).right(by: -Metrics.bigMargin)
        sendPhoneButton.layout(with: keyboardView).bottom(to: .top, by: -Metrics.bigMargin, relatedBy: .lessThanOrEqual)
    }

    func setupRx() {
        viewModel.sendPhoneButtonEnabled.asObservable().bind(to: sendPhoneButton.rx.isEnabled).disposed(by: disposeBag)
    }

    func setAccessibilityIds() {
        view.set(accessibilityId: .askPhoneNumberView)
        closeButton.set(accessibilityId: .askPhoneNumberCloseButton)
        notNowButton.set(accessibilityId: .askPhoneNumberNotNowButton)
        introTextLabel.set(accessibilityId: .askPhoneNumberIntroText)
        letsTalkLabel.set(accessibilityId: .askPhoneNumberLetstalkText)
        phoneTextField.set(accessibilityId: .askPhoneNumberTextfield)
        sendPhoneButton.set(accessibilityId: .askPhoneNumberSendPhoneButton)
    }

    // MARK: Public Methods

    @objc dynamic func closePressed() {
        phoneTextField.resignFirstResponder()
        viewModel.closePressed()
    }

    @objc dynamic func notNowPressed() {
        phoneTextField.resignFirstResponder()
        viewModel.notNowPressed()
    }

    @objc dynamic func sendPhonePressed() {
        phoneTextField.resignFirstResponder()
        viewModel.sendPhonePressed()
    }

    // MARK: UITextFieldDelegate

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let newText = textField.textReplacingCharactersInRange(range, replacementString: string)
        guard newText.replacingOccurrences(of: "-", with: "").isOnlyDigits else { return false }

        if string.count > 1 {
            textField.text = string.addUSPhoneFormatDashes()
            viewModel.updatePhoneNumberFrom(text: newText)
            return false
        } else if range.length == 0 {
            if range.location == Constants.usaFirstDashPosition {
                textField.text?.insert("-", at: String.Index(encodedOffset: Constants.usaFirstDashPosition))
            } else if range.location == Constants.usaSecondDashPosition {
                textField.text?.insert("-", at: String.Index(encodedOffset: Constants.usaSecondDashPosition))
            }
        }

        viewModel.updatePhoneNumberFrom(text: newText)
        return true
    }
}
