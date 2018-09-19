import LGComponents
import UIKit

final class AffiliationPointsView: UIView {
    private enum Layout {
        static let labelHInset: CGFloat = 10
        static let labelVInset: CGFloat = 4
    }

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 14)
        label.textColor = .white
        label.numberOfLines = 1
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
        clipsToBounds = true
        backgroundColor = UIColor.primaryColor
        cornerRadius = 12

        addSubviewForAutoLayout(label)
        let constraints = [label.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                          constant: Layout.labelHInset),
                           label.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                           constant: -Layout.labelHInset),
                           label.topAnchor.constraint(equalTo: topAnchor,
                                                      constant: Layout.labelVInset),
                           label.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                         constant: -Layout.labelVInset)]
        constraints.activate()
    }


    // MARK: - Setup

    func set(points: Int) {
        let pointsText = points < 0 ? "-" : "\(points)"
        label.text = R.Strings.affiliationChallengesPoints(pointsText)
    }
}
