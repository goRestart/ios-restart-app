import LGComponents
import RxCocoa
import RxSwift
import UIKit

final class AffiliationWalletView: UIView {
    private enum Layout {
        static let padding: CGFloat = 24
        static let titleIconSide: CGFloat = 20
        static let titleHSpacing: CGFloat = 8
        static let pointsVSpacing: CGFloat = 60
        static let pointsHSpacing: CGFloat = 4
        static let pointsUnitVSpacing: CGFloat = 5
        static let storeButtonIconSide: CGFloat = 12
        static let storeButtonVCorrection: CGFloat = 6
        static let storeHSpacing: CGFloat = 8
        static let storeChevronHSpacing: CGFloat = 4
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.Strings.affiliationWalletTitle
        label.numberOfLines = 1
        label.font = UIFont.systemMediumFont(size: 14)
        label.textColor = .grayDark
        return label
    }()

    private let titleIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.Affiliation.wallet24.image.tint(color: .grayDark)
        return imageView
    }()

    private let pointsValueLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.numberOfLines = 1
        label.textColor = .lgBlack
        label.font = UIFont.boldSystemFont(ofSize: 48)
        return label
    }()

    private let pointsUnitLabel: UILabel = {
        let label = UILabel()
        label.text = R.Strings.affiliationWalletPointsLabel
        label.numberOfLines = 1
        label.textColor = .lgBlack
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    private let viewStoreButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.Strings.affiliationWalletOpenStoreButton,
                        for: .normal)
        button.setTitleColor(.lgBlack,
                             for: .normal)
        button.titleLabel?.font = UIFont.systemBoldFont(size: 16)
        button.contentHorizontalAlignment = .right
        button.semanticContentAttribute = .forceRightToLeft
        button.setImage(R.Asset.Affiliation.chevronRight24.image
            .tint(color: .lgBlack)
            .resizedImageToSize(CGSize(width: Layout.storeButtonIconSide,
                                       height: Layout.storeButtonIconSide),
                                interpolationQuality: .default),
                        for: .normal)
        button.tintColor = UIColor.lgBlack
        button.isUserInteractionEnabled = false
        button.titleEdgeInsets = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: 0,
                                              right: Layout.storeChevronHSpacing)
        return button
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
        backgroundColor = .white
        layer.borderColor = UIColor.grayLight.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 16

        setupTitle()
        setupPoints()
        setupViewStore()
    }

    private func setupTitle() {
        addSubviewsForAutoLayout([titleIcon, titleLabel])
        let iconConstraints = [titleIcon.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                                  constant: Layout.padding),
                               titleIcon.topAnchor.constraint(equalTo: topAnchor,
                                                              constant: Layout.padding),
                               titleIcon.widthAnchor.constraint(equalToConstant: Layout.titleIconSide),
                               titleIcon.heightAnchor.constraint(equalToConstant: Layout.titleIconSide)]
        iconConstraints.activate()

        let titleConstraints = [titleLabel.leadingAnchor.constraint(equalTo: titleIcon.trailingAnchor,
                                                                    constant: Layout.titleHSpacing),
                                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                                     constant: -Layout.padding),
                                titleLabel.centerYAnchor.constraint(equalTo: titleIcon.centerYAnchor)]
        titleConstraints.activate()
    }

    private func setupPoints() {
        addSubviewsForAutoLayout([pointsValueLabel, pointsUnitLabel])
        let valueConstraints = [pointsValueLabel.leadingAnchor.constraint(equalTo: titleIcon.leadingAnchor),
                                pointsValueLabel.topAnchor.constraint(equalTo: titleIcon.topAnchor,
                                                                      constant: Layout.pointsVSpacing),
                                pointsValueLabel.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                                         constant: -Layout.padding)]
        valueConstraints.activate()

        let unitConstraints = [pointsUnitLabel.leadingAnchor.constraint(equalTo: pointsValueLabel.trailingAnchor,
                                                                        constant: Layout.pointsHSpacing),
                               pointsUnitLabel.topAnchor.constraint(equalTo: pointsValueLabel.topAnchor,
                                                                    constant: Layout.pointsUnitVSpacing)]
        unitConstraints.activate()
    }

    private func setupViewStore() {
        addSubviewForAutoLayout(viewStoreButton)
        let constraints = [viewStoreButton.leadingAnchor.constraint(equalTo: pointsUnitLabel.trailingAnchor,
                                                                    constant: Layout.storeHSpacing),
                           viewStoreButton.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                                     constant: -Layout.padding),
                           viewStoreButton.bottomAnchor.constraint(equalTo: pointsValueLabel.bottomAnchor,
                                                                   constant: -Layout.storeButtonVCorrection)]
        constraints.activate()
    }


    // MARK: - Setup

    func set(points: Int) {
        let text = points < 0 ? "-" : "\(points)"
        pointsValueLabel.text = text
    }
}
