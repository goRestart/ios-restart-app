import Foundation
import LGComponents

final class UserProfileDummyUserDisclaimerView: UIView {

    private let infoImageView = UIImageView()
    private let textLabel = UILabel()

    var infoText: String? {
        didSet {
            textLabel.text = infoText
        }
    }

    private struct Layout {
        static let iconHeight: CGFloat = 16
    }

    // MARK: - Lifecycle

    required init() {
        super.init(frame: CGRect.zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func setupUI() {
        backgroundColor = UIColor.grayBackground
        layer.cornerRadius = LGUIKitConstants.mediumCornerRadius

        infoImageView.image = R.Asset.IconsButtons.icInfoDark.image

        textLabel.font = UIFont.systemRegularFont(size: 13)
        textLabel.textColor = UIColor.grayDisclaimerText
        textLabel.numberOfLines = 2
        textLabel.text = infoText
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.2
        setupConstraints()
    }

    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubviewsForAutoLayout([infoImageView, textLabel])

        let constraints = [
            infoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: Metrics.shortMargin),
            infoImageView.heightAnchor.constraint(equalToConstant: Layout.iconHeight),
            infoImageView.widthAnchor.constraint(equalTo: infoImageView.heightAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.leftAnchor.constraint(equalTo: infoImageView.rightAnchor, constant: Metrics.shortMargin),
            textLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -Metrics.bigMargin)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
