import LGComponents
import UIKit

final class AffiliationChallengeStepView: UIView {
    enum Status {
        case todo(isHighlighted: Bool)
        case processing
        case completed
    }
    private enum Layout {
        static let padding: CGFloat = 4
        static let stepIconSide: CGFloat = 20
        static let hSpacing: CGFloat = 12
    }
    private enum Color {
        static let green = UIColor(rgb: 0xa3ce71)
    }

    private let stepIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.cornerRadius = Layout.stepIconSide/2
        imageView.layer.borderColor = UIColor.grayDark.cgColor
        return imageView
    }()

    private let stepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 12)
        label.textColor = .grayDark
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 17)
        label.textColor = .grayDark
        label.numberOfLines = 3
        return label
    }()


    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewsForAutoLayout([stepIcon, stepLabel, titleLabel])
        let constraints = [stepIcon.leadingAnchor.constraint(equalTo: leadingAnchor),
                           stepIcon.topAnchor.constraint(equalTo: titleLabel.topAnchor),
                           stepIcon.widthAnchor.constraint(equalToConstant: Layout.stepIconSide),
                           stepIcon.heightAnchor.constraint(equalToConstant: Layout.stepIconSide),
                           stepLabel.leadingAnchor.constraint(equalTo: stepIcon.leadingAnchor),
                           stepLabel.trailingAnchor.constraint(equalTo: stepIcon.trailingAnchor),
                           stepLabel.topAnchor.constraint(equalTo: stepIcon.topAnchor),
                           stepLabel.bottomAnchor.constraint(equalTo: stepIcon.bottomAnchor),
                           titleLabel.leadingAnchor.constraint(equalTo: stepIcon.trailingAnchor,
                                                               constant: Layout.hSpacing),
                           titleLabel.topAnchor.constraint(equalTo: topAnchor,
                                                           constant: Layout.padding),
                           titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                              constant: -Layout.padding),
                           titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)]
        constraints.activate()
    }


    // MARK: - Setup

    func set(title: String) {
        titleLabel.text = title
    }

    func set(stepNumber: Int) {
        stepLabel.text = "\(stepNumber)"
    }

    func set(status: Status) {
        switch status {
        case let .todo(isHighlighted):
            stepIcon.image = nil
            stepIcon.layer.borderWidth = 2
            let color: UIColor = isHighlighted ? .grayDark : .grayLight
            stepIcon.layer.borderColor = color.cgColor
            stepIcon.backgroundColor = .white
            stepLabel.isHidden = false
            stepLabel.textColor = color
            titleLabel.textColor = color
        case .processing:
            let color = UIColor.grayDark
            stepIcon.image = R.Asset.Affiliation.icnClockFill24.image.tint(color: color)
            stepIcon.layer.borderWidth = 0
            stepIcon.backgroundColor = .white
            stepLabel.isHidden = true
            titleLabel.textColor = color
        case .completed:
            stepIcon.image = R.Asset.Affiliation.icnCheck.image.tint(color: .white)
            stepIcon.layer.borderWidth = 0
            stepIcon.backgroundColor = Color.green
            stepLabel.isHidden = true
            titleLabel.textColor = .grayLight
        }
    }
}


