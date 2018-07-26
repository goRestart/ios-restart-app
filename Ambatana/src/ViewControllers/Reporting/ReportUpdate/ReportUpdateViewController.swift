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

    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = UIStackViewDistribution.equalSpacing
        stackView.spacing = 22
        stackView.alignment = .center
        return stackView
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

    private let feedbackButtons: [UIButton] = {
        var array: [UIButton] = []
        for i in 0...4 {
            let button = UIButton()
            button.setImage(R.Asset.IconsButtons.icEmojiYes.image, for: .normal)
            button.contentMode = .scaleAspectFit
            button.tag = i
            array.append(button)
        }
        return array
    }()

    private struct Layout {
        static let verticalMargin: CGFloat = 32
        static let contentViewMargin: CGFloat = 15
        static let imageSize = CGSize(width: 159, height: 159)
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
        feedbackContainerView.addSubviewsForAutoLayout([feedbackSeparator, feedbackTitle, buttonsStackView])
        buttonsStackView.addArrangedSubviews(feedbackButtons)
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
            buttonsStackView.topAnchor.constraint(equalTo: feedbackTitle.bottomAnchor, constant: Metrics.bigMargin),
            buttonsStackView.centerXAnchor.constraint(equalTo: feedbackContainerView.centerXAnchor)
            ]

        var buttonConstraints: [NSLayoutConstraint] = []
        feedbackButtons.forEach { button in
            let height = button.heightAnchor.constraint(equalToConstant: 38)
            let width = button.widthAnchor.constraint(equalToConstant: 38)
            buttonConstraints.append(contentsOf: [height, width])
        }

        NSLayoutConstraint.activate(constraints)
        NSLayoutConstraint.activate(buttonConstraints)
    }

    @objc private func didTapButton(sender: UIButton) {
        print("did tap button \(sender.tag)")
    }
}
