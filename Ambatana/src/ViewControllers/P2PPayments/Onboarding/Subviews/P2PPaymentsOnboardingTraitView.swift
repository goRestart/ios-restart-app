import UIKit
import LGComponents

final class P2PPaymentsOnboardingTraitView: UIView {
    private enum Layout {
        static let horizontalInset: CGFloat = 24
        static let imageToTextSpacing: CGFloat = 16
        static let titleToSubtitleSpacing: CGFloat = 8
        static let imageWidth: CGFloat = 44
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemBoldFont(size: 20)
        label.textColor = .lgBlack
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .grayDark
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    init(title: String, subtitle: String, image: UIImage?) {
        super.init(frame: .zero)
        setup(title: title, subtitle: subtitle, image: image)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup(title: String, subtitle: String, image: UIImage?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        imageView.image = image
        addSubviewsForAutoLayout([imageView, titleLabel, subtitleLabel])
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.horizontalInset),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Layout.imageWidth),

            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Layout.imageToTextSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.horizontalInset),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.titleToSubtitleSpacing),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }
}
