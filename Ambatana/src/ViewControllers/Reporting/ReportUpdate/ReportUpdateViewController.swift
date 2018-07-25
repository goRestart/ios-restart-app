import UIKit
import LGComponents

final class ReportUpdateViewController: BaseViewController {

    private let viewModel: ReportUpdateViewModel

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.bigMargin, right: 0)
        return scrollView
    }()

    private let containerView: UIView = {
        let view = UIView()
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .reportSentTitleText
        label.textColor = .blackText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .bigBodyFont
        label.textColor = .blackText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let feedbackContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let feedbackSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .grayLight
        return view
    }()

    private let feedbackTitle: UILabel = {
        let label = UILabel()
        label.font = .reportCellTitleFont
        label.textColor = .lgBlack
        label.text = R.Strings.reportingListingUpdateFeedbackTitle
        return label
    }()

    private struct Layout {
        static let verticalMargin: CGFloat = 32
        static let contentViewMargin: CGFloat = 15
        static let imageSize = CGSize(width: 159, height: 159)
        static let buttonMiniSize: CGFloat = 38
        static let buttonBigSize: CGFloat = 49
    }

    private let verySadButton = ReportUpdateButton(type: .verySad)
    private let sadButton = ReportUpdateButton(type: .sad)
    private let neutralButton = ReportUpdateButton(type: .neutral)
    private let happyButton = ReportUpdateButton(type: .happy)
    private let veryHappyButton = ReportUpdateButton(type: .veryHappy)

    private var feedbackButtons: [ReportUpdateButton] {
        return [verySadButton, sadButton, neutralButton, happyButton, veryHappyButton]
    }

    init(viewModel: ReportUpdateViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
        setNavBarBackButton(R.Asset.IconsButtons.navbarClose.image, selector: #selector(didTapClose))
    }

    @objc private func didTapClose() {
        viewModel.didTapClose()
    }

    private func setupUI() {
        view.addSubviewForAutoLayout(scrollView)
        view.backgroundColor = .white
        scrollView.addSubviewForAutoLayout(containerView)
        containerView.addSubviewsForAutoLayout([imageView, titleLabel, messageLabel])

        titleLabel.text = viewModel.type.title
        messageLabel.attributedText = viewModel.type.attributedText
        imageView.image = R.Asset.Reporting.communityBadge.image

        view.addSubviewForAutoLayout(feedbackContainerView)
        feedbackContainerView.addSubviewsForAutoLayout([feedbackSeparator, feedbackTitle, verySadButton, sadButton,
                                                        neutralButton, happyButton, veryHappyButton])
        feedbackButtons.forEach { button in
            button.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        }
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: safeTopAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Layout.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: Layout.imageSize.height),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Layout.verticalMargin),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Layout.contentViewMargin),
            titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Layout.contentViewMargin),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.verticalMargin),
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            messageLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Layout.contentViewMargin),
            messageLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Layout.contentViewMargin),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            feedbackContainerView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            feedbackContainerView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            feedbackContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            feedbackContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            feedbackContainerView.heightAnchor.constraint(equalToConstant: 128),
            feedbackSeparator.topAnchor.constraint(equalTo: feedbackContainerView.topAnchor),
            feedbackSeparator.leftAnchor.constraint(equalTo: feedbackContainerView.leftAnchor, constant: Metrics.margin),
            feedbackSeparator.rightAnchor.constraint(equalTo: feedbackContainerView.rightAnchor, constant: -Metrics.margin),
            feedbackSeparator.heightAnchor.constraint(equalToConstant: 1),
            feedbackTitle.topAnchor.constraint(equalTo: feedbackContainerView.topAnchor, constant: Metrics.bigMargin),
            feedbackTitle.centerXAnchor.constraint(equalTo: feedbackContainerView.centerXAnchor),
            neutralButton.centerXAnchor.constraint(equalTo: feedbackContainerView.centerXAnchor),
            neutralButton.topAnchor.constraint(equalTo: feedbackTitle.bottomAnchor, constant: 39),
            sadButton.centerYAnchor.constraint(equalTo: neutralButton.centerYAnchor),
            sadButton.centerXAnchor.constraint(equalTo: neutralButton.centerXAnchor, constant: -50),
            verySadButton.centerYAnchor.constraint(equalTo: neutralButton.centerYAnchor),
            verySadButton.centerXAnchor.constraint(equalTo: sadButton.centerXAnchor, constant: -50),
            happyButton.centerYAnchor.constraint(equalTo: neutralButton.centerYAnchor),
            happyButton.centerXAnchor.constraint(equalTo: neutralButton.centerXAnchor, constant: 50),
            veryHappyButton.centerYAnchor.constraint(equalTo: neutralButton.centerYAnchor),
            veryHappyButton.centerXAnchor.constraint(equalTo: happyButton.centerXAnchor, constant: 50)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func didTapButton(sender: ReportUpdateButton) {
        print("did tap button \(sender.tag)")
    }
}
