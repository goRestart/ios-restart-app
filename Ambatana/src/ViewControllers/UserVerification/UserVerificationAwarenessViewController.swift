import Foundation
import LGComponents

final class UserVerificationAwarenessViewController: BaseViewController {

    private struct Layout {
        static let verticalMargin: CGFloat = 5.0
        static let imageHeight: CGFloat = 100.0
        static let verifiedBadgeHeight: CGFloat = 30
        static let closeButtonHeight: CGFloat = 33
    }

    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .grayLight
        imageView.layer.cornerRadius = Layout.imageHeight / 2
        imageView.clipsToBounds = true
        return imageView
    }()

    private let badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.icKarmaBadgeActive.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .lgBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = Layout.closeButtonHeight / 2
        button.backgroundColor = UIColor.grayLight.withAlphaComponent(0.9)
        return button
    }()

    private let button: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .verySmallBold))
        return button
    }()

    private let viewModel: UserVerificationAwarenessViewModel

    init(viewModel: UserVerificationAwarenessViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addSubviewsForAutoLayout([container, closeButton])
        container.addSubviewsForAutoLayout([avatarImageView, badgeImageView, label, button])
        setupConstraints()

        label.text = "Here's a pro tip - did you know that verified users make better deals?\n\nComplete and verify your profile today!"
        button.setTitle("Complete profile", for: .normal)
        if let url = viewModel.avatarURL {
            avatarImageView.lg_setImageWithURL(url)
        } else {
            avatarImageView.image = viewModel.placeholder
        }
    }

    func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 37),
            container.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -37),
            avatarImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
            avatarImageView.heightAnchor.constraint(equalToConstant: Layout.imageHeight),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),
            badgeImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            badgeImageView.rightAnchor.constraint(equalTo: avatarImageView.rightAnchor),
            badgeImageView.heightAnchor.constraint(equalToConstant: Layout.verifiedBadgeHeight),
            badgeImageView.widthAnchor.constraint(equalTo: badgeImageView.heightAnchor),
            label.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Metrics.bigMargin),
            label.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Metrics.bigMargin),
            label.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Metrics.bigMargin),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Metrics.bigMargin),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -30),
            button.heightAnchor.constraint(equalToConstant: 34),
            closeButton.heightAnchor.constraint(equalToConstant: Layout.closeButtonHeight),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),
            closeButton.rightAnchor.constraint(equalTo: container.rightAnchor, constant: Metrics.shortMargin),
            closeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: -Metrics.shortMargin)
        ]
        constraints.activate()
    }
}
