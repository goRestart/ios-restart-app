import UIKit
import LGComponents
import RxSwift
import RxCocoa


final class P2PPaymentsEnterPayCodeViewController: BaseViewController, VerificationCodeTextFieldDelegate {
    private let viewModel: P2PPaymentsEnterPayCodeViewModel
    private let disposeBag = DisposeBag()

    private let buyerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.cornerRadius = 72 / 2
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemBoldFont(size: 18)
        label.textColor = .lgBlack
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.textAlignment = .center
        return label
    }()

    private let verificationCodetextField = VerificationCodeTextField(digits: 4, inputType: .alphaNumeric)

    private let attemptsTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 11)
        label.textColor = .grayRegular
        label.text = R.Strings.paymentsEnterPayCodeAttempsLabel
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.hidesWhenStopped = true
        return view
    }()

    init(viewModel: P2PPaymentsEnterPayCodeViewModel) {
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
        setNavBarTitleStyle(NavBarTitleStyle.text(R.Strings.paymentsEnterPayCodeNavbarTitle))
        setNavBarBackgroundStyle(NavBarBackgroundStyle.transparent(substyle: NavBarTransparentSubStyle.light))
    }

    @objc private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    private func setup() {
        view.backgroundColor = UIColor.white
        verificationCodetextField.delegate = self
        view.addSubviewsForAutoLayout([buyerImageView,
                                       descriptionLabel,
                                       verificationCodetextField,
                                       attemptsTextLabel,
                                       activityIndicator])
        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buyerImageView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 4),
            buyerImageView.widthAnchor.constraint(equalToConstant: 72),
            buyerImageView.heightAnchor.constraint(equalToConstant: 72),

            descriptionLabel.topAnchor.constraint(equalTo: buyerImageView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            verificationCodetextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verificationCodetextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),

            attemptsTextLabel.topAnchor.constraint(equalTo: verificationCodetextField.bottomAnchor, constant: 12),
            attemptsTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupRx() {
        let bindings = [
            viewModel.showLoadingIndicator.drive(activityIndicator.rx.isAnimating),
            viewModel.descriptionText.drive(descriptionLabel.rx.text),
            viewModel.hideCodeTextField.drive(verificationCodetextField.rx.isHidden),
            viewModel.hideCodeTextField.drive(attemptsTextLabel.rx.isHidden),
        ]
        viewModel.hideCodeTextField.drive(onNext: { [weak self] hide in
            guard !hide else { return }
            self?.verificationCodetextField.clearText()
            self?.verificationCodetextField.becomeFirstResponder()
        }).disposed(by: disposeBag)
        viewModel.buyerImageURL.drive(onNext: { [weak self] url in
            guard let url = url else { return }
            self?.buyerImageView.lg_setImageWithURL(url)
        }).disposed(by: disposeBag)
        bindings.forEach { [disposeBag] in $0.disposed(by: disposeBag) }
    }

    func didEndEditingWith(code: String) {
        viewModel.payCodeEntered(code)
    }
}
