import UIKit
import LGComponents

final class ReportSentViewController: BaseViewController {

    private let viewModel: ReportSentViewModel

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
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

    private struct Layout {
        static let verticalMargin: CGFloat = 32
        static let contentViewMargin: CGFloat = 15
        static let imageSize = CGSize(width: 159, height: 159)
    }

    init(viewModel: ReportSentViewModel) {
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
        scrollView.addSubviewsForAutoLayout([imageView, titleLabel, messageLabel])
        setupConstraints()

        titleLabel.text = viewModel.type.title
        messageLabel.attributedText = viewModel.type.attributedMessage(includingReviewText: true, userName: "Isaac R.")
        imageView.image = R.Asset.Reporting.rocket.image
    }

    private func setupConstraints() {
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: safeTopAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Layout.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: Layout.imageSize.height),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Layout.verticalMargin),
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            titleLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: Layout.contentViewMargin),
            titleLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -Layout.contentViewMargin),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.verticalMargin),
            messageLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            messageLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: Layout.contentViewMargin),
            messageLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -Layout.contentViewMargin),
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
