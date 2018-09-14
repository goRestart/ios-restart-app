import Foundation
import LGComponents

final class UserVerificationAwarenessViewController: BaseViewController {

    private struct Layout {
        static let verticalMargin: CGFloat = 5.0
        static let imageHeight: CGFloat = 100.0
        static let verifiedBadgeHeight: CGFloat = 30
        static let closeButtonHeight: CGFloat = 33
        static let containerMargin: CGFloat = 37
        static let avatarMargin: CGFloat = 30
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
        imageView.frame = CGRect.zero
        imageView.alpha = 0
        imageView.clipsToBounds = true
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .lgBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let laterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitleColor(UIColor.black.withAlphaComponent(0.34), for: .normal)
        button.setTitle(R.Strings.promoteBumpLaterButton, for: .normal)
        button.titleLabel?.font = UIFont.verySmallBoldButtonFont
        return button
    }()

    private let button: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .verySmallBold))
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.bigMargin, bottom: 0, right: Metrics.bigMargin)
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
        viewModel.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        animateBadge()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addSubviewForAutoLayout(container)
        container.addSubviewsForAutoLayout([avatarImageView, badgeImageView, label, button, laterButton])
        setupConstraints()

        label.attributedText = messageText()
        button.setTitle(R.Strings.profileVerificationsAwarenessViewButton, for: .normal)
        if let url = viewModel.avatarURL {
            avatarImageView.lg_setImageWithURL(url)
        } else {
            avatarImageView.image = viewModel.placeholder
        }
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        laterButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    private func messageText() -> NSAttributedString {
        let boldText = R.Strings.profileVerificationsAwarenessViewBoldText
        let fullText = R.Strings.profileVerificationsAwarenessViewText(boldText)
        let message = NSMutableAttributedString(string: fullText,
                                                attributes: [.font: UIFont.verificationsAwarenessMessageFont,
                                                             .foregroundColor: UIColor.lgBlack])
        let range = (fullText as NSString).range(of: boldText)
        message.addAttribute(.font, value: UIFont.verificationsAwarenessMessageBoldFont, range: range)
        return message
    }

    private func animateBadge() {
        self.badgeImageView.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0.5,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5,
                       options: [], animations: {
                        self.badgeImageView.alpha = 1.0
                        self.badgeImageView.transform = .identity
        }, completion: nil)
    }

    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.containerMargin),
            container.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.containerMargin),
            avatarImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: Layout.avatarMargin),
            avatarImageView.heightAnchor.constraint(equalToConstant: Layout.imageHeight),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),
            badgeImageView.centerXAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: -Layout.verifiedBadgeHeight/2),
            badgeImageView.centerYAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: -Layout.verifiedBadgeHeight/2),
            label.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Metrics.bigMargin),
            label.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Metrics.bigMargin),
            label.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Metrics.bigMargin),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Metrics.bigMargin),
            button.heightAnchor.constraint(equalToConstant: 34),
            laterButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            laterButton.topAnchor.constraint(equalTo: button.bottomAnchor, constant: Metrics.shortMargin),
            laterButton.heightAnchor.constraint(equalToConstant: 34),
            laterButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Metrics.bigMargin),
        ]
        constraints.activate()
    }

    @objc private func didTapButton() {
        viewModel.openVerifications()
    }

    @objc private func didTapClose() {
        viewModel.close()
    }
}
