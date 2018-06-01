import LGComponents
import GoogleSignIn
import UIKit

final class EmbeddedLoginViewController: UIViewController, GIDSignInUIDelegate, SignUpViewModelDelegate {
    private let viewModel: EmbeddedLoginViewModel

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        stack.distribution = .fillProportionally
        stack.alignment = .center
        return stack
    }()
    private let facebookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Facebook", for: .normal)
        button.addTarget(self, action: #selector(facebookButtonPressed), for: .touchUpInside)
        return button
    }()
    private let googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Google", for: .normal)
        button.addTarget(self, action: #selector(googleButtonPressed), for: .touchUpInside)
        return button
    }()
    private let emailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Email", for: .normal)
        button.addTarget(self, action: #selector(emailButtonPressed), for: .touchUpInside)
        return button
    }()


    // MARK: - Lifecycle

    init(viewModel: EmbeddedLoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil,
                   bundle: nil)
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
        setupStackView()
    }

    private func setupStackView() {
        view.addSubviewForAutoLayout(stackView)
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: safeTopAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
                                     stackView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: safeTrailingAnchor)])
        [facebookButton, googleButton, emailButton].forEach { stackView.addArrangedSubview($0) }
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
