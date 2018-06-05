import Foundation
import LGComponents

final class UserProfileRelationView: UIView {

    private let iconImageView = UIImageView()
    private let textLabel = UILabel()

    private struct Layout {
        static let iconHeight: CGFloat = 12
        static let textMargin: CGFloat = 5
    }

    var userRelationText: String? {
        didSet {
            textLabel.text = userRelationText
        }
    }

    init() {
        super.init(frame: .zero)
        setupUI()
        setupAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewsForAutoLayout([iconImageView, textLabel])
        iconImageView.image = R.Asset.BackgroundsAndImages.icBlocked.image

        textLabel.textColor = UIColor.primaryColor
        textLabel.font = UIFont.smallButtonFont
        clipsToBounds = true
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints = [
            iconImageView.leftAnchor.constraint(equalTo: leftAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconHeight),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: Layout.textMargin)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupAccessibilityIds() {
        textLabel.set(accessibilityId: .userHeaderExpandedRelationLabel)
    }
}
