import LGComponents
import GoogleSignIn
import UIKit

final class EmbeddedLoginViewController: BaseViewController, GIDSignInUIDelegate, SignUpViewModelDelegate {
    private let viewModel: EmbeddedLoginViewModel

    private let stackView: UIStackView
    private let facebookButton: UIButton
    private let googleButton: UIButton
    private let emailButton: UIButton


    // MARK: - Lifecycle

    init(viewModel: EmbeddedLoginViewModel) {
        self.viewModel = viewModel
        self.stackView = UIStackView()
        self.facebookButton = UIButton(type: .system)
        self.googleButton = UIButton(type: .system)
        self.emailButton = UIButton(type: .system)
        super.init(viewModel: viewModel,
                   nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Embedded Login"
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.white
        setupFacebookButton()
        setupGoogleButton()
        setupEmailButton()
        setupStackView()
    }

    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        let constraints: [NSLayoutConstraint]
        if #available(iOS 11, *) {
            constraints = [stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                           stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                           stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                           stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)]
        } else {
            constraints = [stackView.topAnchor.constraint(equalTo: view.topAnchor),
                           stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                           stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                           stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)]
        }
        constraints.forEach { $0.isActive = true }

        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        [facebookButton, googleButton, emailButton].forEach { stackView.addArrangedSubview($0) }
    }

    private func setupFacebookButton() {
        facebookButton.setTitle("Facebook", for: .normal)
        facebookButton.addTarget(self, action: #selector(facebookButtonPressed), for: .touchUpInside)
    }

    private func setupGoogleButton() {
        googleButton.setTitle("Google", for: .normal)
        googleButton.addTarget(self, action: #selector(googleButtonPressed), for: .touchUpInside)
    }

    private func setupEmailButton() {
        emailButton.setTitle("Email", for: .normal)
        emailButton.addTarget(self, action: #selector(emailButtonPressed), for: .touchUpInside)
    }


    // MARK: - Actions

    @objc func facebookButtonPressed() {
        viewModel.facebookButtonPressed()
    }

    @objc func googleButtonPressed() {
        GIDSignIn.sharedInstance().uiDelegate = self
        viewModel.googleButtonPressed()
    }

    @objc func emailButtonPressed() {
        viewModel.emailButtonPressed()
    }
}
