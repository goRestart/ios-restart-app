import UIKit
import LGComponents
import RxSwift
import RxCocoa


final class P2PPaymentsPayoutPersonalInfoView: UIView {
    var registrationParams: P2PPaymentsPayoutViewModel.RegistrationParams {
        return P2PPaymentsPayoutViewModel.RegistrationParams(firstName: firstNameTextField.text ?? "",
                                                             lastName: lastNameTextField.text ?? "",
                                                             dateOfBirth: datePicker.date,
                                                             ssnLastFour: ssnLastFourTextField.text ?? "",
                                                             address: addressTextField.text ?? "",
                                                             zipCode: zipCodeTextField.text ?? "",
                                                             city: cityTextField.text ?? "",
                                                             state: stateTextField.text ?? "")
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()

    private enum Layout {
        static let contentHorizontalMargin: CGFloat = 24
        static let buttonHeight: CGFloat = 55
        static let buttonBottomMargin: CGFloat = 16
    }

    private let formTitleLabel: UILabel =  {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 14)
        label.textColor = UIColor.lgBlack
        label.text = R.Strings.paymentsPayoutPersonalInfoTitleLabel
        return label
    }()

    private let firstNameTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText(R.Strings.paymentsPayoutPersonalInfoFirstNamePlaceholder)
        textField.returnKeyType = .next
        return textField
    }()

    private let lastNameTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText(R.Strings.paymentsPayoutPersonalInfoLastNamePlaceholder)
        textField.returnKeyType = .next
        return textField
    }()

    private let dateOfBirthTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText(R.Strings.paymentsPayoutPersonalInfoDateOfBirthPlaceholder)
        textField.returnKeyType = .next
        return textField
    }()

    private let ssnLastFourTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText(R.Strings.paymentsPayoutPersonalInfoSsnPlaceholder)
        textField.returnKeyType = .next
        return textField
    }()

    private let addressTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText(R.Strings.paymentsPayoutPersonalInfoAddressPlaceholder)
        textField.returnKeyType = .next
        return textField
    }()

    private let zipCodeTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText(R.Strings.paymentsPayoutPersonalInfoZipCodePlaceholder)
        textField.returnKeyType = .next
        return textField
    }()

    private let cityTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText(R.Strings.paymentsPayoutPersonalInfoCityPlaceholder)
        textField.returnKeyType = .next
        return textField
    }()

    private let stateTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText(R.Strings.paymentsPayoutPersonalInfoStatePlaceholder)
        textField.returnKeyType = .done
        return textField
    }()

    private let countryTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText(R.Strings.paymentsPayoutPersonalInfoCountryPlaceholder)
        textField.text = "United States"
        textField.isUserInteractionEnabled = false
        return textField
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()

    fileprivate let actionButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle(R.Strings.paymentsPayoutPersonalInfoRegisterButton, for: .normal)
        return button
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        return stackView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private var bottomContraint: NSLayoutConstraint?
    private let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        configureDatePicker()
        configureTextFields()
        configureStackView()
        scrollView.addSubviewsForAutoLayout([stackView, actionButton])
        addSubviewForAutoLayout(scrollView)
        setupConstraints()
        setupRx()
    }

    private func configureDatePicker() {
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        dateOfBirthTextField.inputView = datePicker
    }

    private func configureStackView() {
        stackView.addArrangedSubviews([
            formTitleLabel,
            firstNameTextField,
            lastNameTextField,
            dateOfBirthTextField,
            ssnLastFourTextField,
            addressTextField,
            zipCodeTextField,
            cityTextField,
            stateTextField,
            countryTextField,
        ])
    }

    private func configureTextFields() {
        firstNameTextField.nextResponderTextField = lastNameTextField
        lastNameTextField.nextResponderTextField = dateOfBirthTextField
        dateOfBirthTextField.nextResponderTextField = ssnLastFourTextField
        ssnLastFourTextField.nextResponderTextField = addressTextField
        addressTextField.nextResponderTextField = zipCodeTextField
        zipCodeTextField.nextResponderTextField = cityTextField
        cityTextField.nextResponderTextField = stateTextField
        [firstNameTextField,
         lastNameTextField,
         dateOfBirthTextField,
         ssnLastFourTextField,
         addressTextField,
         zipCodeTextField,
         cityTextField,
         stateTextField,
         countryTextField].forEach { textfield in
            textfield.addTarget(self,
                                action: #selector(textFieldDidBeginEditing(textField:)),
                                for: UIControlEvents.editingDidBegin)
        }
    }

    private func setupConstraints() {
        bottomContraint = scrollView.bottomAnchor.constraint(equalTo: safeBottomAnchor)
        bottomContraint?.isActive = true
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeTopAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -24),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),

            actionButton.heightAnchor.constraint(equalToConstant: 55),
            actionButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -48),
            actionButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 32),
            actionButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -12),
        ])
    }

    private func setupRx() {
        Driver
            .combineLatest([
                firstNameTextField.rx.isEmpty,
                lastNameTextField.rx.isEmpty,
                dateOfBirthTextField.rx.isEmpty,
                ssnLastFourTextField.rx.isEmpty,
                addressTextField.rx.isEmpty,
                zipCodeTextField.rx.isEmpty,
                cityTextField.rx.isEmpty,
                stateTextField.rx.isEmpty,
                countryTextField.rx.isEmpty,
            ])
            .map { !$0.contains(true) }
            .drive(actionButton.rx.isEnabled).disposed(by: disposeBag)
    }

    @objc private func dateChanged() {
        let dateString = P2PPaymentsPayoutPersonalInfoView.dateFormatter.string(from: datePicker.date)
        dateOfBirthTextField.text = dateString
    }

    @objc private func textFieldDidBeginEditing(textField: UITextField) {
        let adjustedFrame = textField.frame.insetBy(dx: 0, dy: -50)
        scrollView.scrollRectToVisible(adjustedFrame, animated: true)
    }
}

// MARK: - Rx

extension Reactive where Base: P2PPaymentsPayoutPersonalInfoView {
    var registerButtonTap: ControlEvent<Void> {
        return base.actionButton.rx.tap
    }
}
