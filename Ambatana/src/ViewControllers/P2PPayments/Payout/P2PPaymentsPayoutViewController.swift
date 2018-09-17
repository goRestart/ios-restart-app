import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize all texts

final class P2PPaymentsPayoutViewController: BaseViewController {
    private let viewModel: P2PPaymentsPayoutViewModel
    private let disposeBag = DisposeBag()

    private let firstNameTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("First name")
        return textField
    }()

    private let lastNameTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("Last name")
        return textField
    }()

    private let dateOfBirthTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("Date of birth")
        return textField
    }()

    private let ssnLastFourTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("SSN last 4")
        return textField
    }()

    private let addressTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("Address")
        return textField
    }()

    private let zipCodeTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("Zip code")
        return textField
    }()

    private let cityTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("City")
        return textField
    }()

    private let stateTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("State")
        return textField
    }()

    private let countryTextField: P2PPaymentsTextField = {
        let textField = P2PPaymentsTextField()
        textField.setPlaceholderText("First name")
        textField.text = "United States"
        textField.isUserInteractionEnabled = false
        return textField
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        return stackView
    }()

    init(viewModel: P2PPaymentsPayoutViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        setNavBarCloseButton(#selector(closeButtonPressed), icon: R.Asset.P2PPayments.close.image)
        setNavBarTitleStyle(NavBarTitleStyle.text("Payout"))
        setNavBarBackgroundStyle(NavBarBackgroundStyle.transparent(substyle: NavBarTransparentSubStyle.light))
    }

    @objc private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    private func setup() {
        view.backgroundColor = UIColor.white
        firstNameTextField.nextResponderTextField = lastNameTextField
        lastNameTextField.nextResponderTextField = dateOfBirthTextField
        dateOfBirthTextField.nextResponderTextField = ssnLastFourTextField
        ssnLastFourTextField.nextResponderTextField = addressTextField
        addressTextField.nextResponderTextField = zipCodeTextField
        zipCodeTextField.nextResponderTextField = cityTextField
        cityTextField.nextResponderTextField = stateTextField
        stackView.addArrangedSubviews([
            firstNameTextField,
            lastNameTextField,
            dateOfBirthTextField,
            ssnLastFourTextField,
            addressTextField,
            zipCodeTextField,
            cityTextField,
            stateTextField,
            countryTextField
        ])
        view.addSubviewForAutoLayout(stackView)
        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupRx() {
    }
}
