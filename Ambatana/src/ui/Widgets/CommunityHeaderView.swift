import Foundation
import LGComponents

final class CommunityHeaderView: UIView {

    static var viewHeight: CGFloat {
        return (UIScreen.main.bounds.width - Metrics.margin*2) / Layout.bannerAspectRatio
    }

    private struct Layout {
        static let cornerRadius: CGFloat = 8
        static let sideMargin: CGFloat = 26
        static let bannerAspectRatio: CGFloat = 2.96
    }

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryColor
        view.layer.cornerRadius = Layout.cornerRadius
        return view
    }()

    private let topLeftBubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = R.Asset.IconsButtons.Community.shapeBrightblue.image
        return imageView
    }()

    private let topRightBubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = R.Asset.IconsButtons.Community.shapeDarkblue.image
        return imageView
    }()

    private let bottomLeftBubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = R.Asset.IconsButtons.Community.shapeYellow.image
        return imageView
    }()

    private let centerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = R.Asset.IconsButtons.Community.icCommunityBanner.image
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.communityBannerTitleFont
        label.text = "Join the letgo community!"
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewForAutoLayout(containerView)
        containerView.addSubviewsForAutoLayout([topLeftBubbleImageView, topRightBubbleImageView,
                                                bottomLeftBubbleImageView, centerImageView, titleLabel])
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: Metrics.shortMargin),
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Metrics.shortMargin),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            topLeftBubbleImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            topLeftBubbleImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            topRightBubbleImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            topRightBubbleImageView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            bottomLeftBubbleImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            bottomLeftBubbleImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: Layout.sideMargin),
            titleLabel.rightAnchor.constraint(equalTo: centerImageView.leftAnchor, constant: -Metrics.margin),
            centerImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerImageView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -Layout.sideMargin)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
