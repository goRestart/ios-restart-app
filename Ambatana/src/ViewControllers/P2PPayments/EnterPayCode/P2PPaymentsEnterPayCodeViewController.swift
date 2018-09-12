import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize all texts

final class P2PPaymentsEnterPayCodeViewController: BaseViewController {
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
        label.text = "Enter the 4-digit code that buyer Susie Fuller has shared with you"
        return label
    }()

    private let verificationCodetextField = VerificationCodeTextField(digits: 4, inputType: .alphaNumeric)

    private let attemptsTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 11)
        label.textColor = .grayRegular
        label.text = "3 attempts per minute"
        return label
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
        verificationCodetextField.becomeFirstResponder()
    }

    private func setupNavigationBar() {
        setNavBarTitleStyle(NavBarTitleStyle.text("Offer"))
        setNavBarBackgroundStyle(NavBarBackgroundStyle.transparent(substyle: NavBarTransparentSubStyle.light))
    }

    private func setup() {
        view.backgroundColor = UIColor.white
        view.addSubviewsForAutoLayout([buyerImageView,
                                       descriptionLabel,
                                       verificationCodetextField,
                                       attemptsTextLabel])
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
        ])
    }

    private func setupRx() {
//        let bindings = [
//        ]
//        bindings.forEach { [disposeBag] in $0.disposed(by: disposeBag) }
    }
}
