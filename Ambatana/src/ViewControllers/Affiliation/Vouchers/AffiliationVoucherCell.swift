import LGComponents
import LGCoreKit

private enum Layout {
    enum Size {
        static let button = CGSize(width: 90, height: 32)
        static let partner = CGSize(width: 40, height: 40)
    }
    static let stackViewEdges = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
}

final class AffiliationVoucherCell: UITableViewCell, ReusableCell {
    private var resendWidth: NSLayoutConstraint?

    private let partnerIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.Asset.Affiliation.Partners.amazon.image
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()

    private let voucherTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 18)
        label.textAlignment = .left
        label.textColor = .lgBlack
        label.text = R.Strings.affiliationStoreRewardsAmazon5
        return label
    }()

    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 14)
        label.textAlignment = .left
        label.textColor = .grayRegular
        label.text = R.Strings.affiliationStorePoints("10")
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 14)
        label.textAlignment = .left
        label.textColor = .grayDark
        label.text = "July 21st"
        return label
    }()

    private let resendButton: LetgoButton = {
        let button = LetgoButton.init(withStyle: .primary(fontSize: .medium))
        button.setTitle(R.Strings.affiliationStoreResendVoucher, for: .normal)
        return button
    }()

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    private func setupUI() {
        let subheadlineStackView = UIStackView.horizontal([pointsLabel, dateLabel, UIView()])
        let verticalStackView = UIStackView.vertical([voucherTitle, subheadlineStackView, UIView()])
        let buttonStackView = UIStackView.vertical([UIView(), resendButton, UIView()])
        let mainStackView = UIStackView.horizontal([partnerIcon, verticalStackView, buttonStackView])
        mainStackView.spacing = 20
        
        contentView.addSubviewsForAutoLayout([mainStackView])
        let resendWidth = resendButton.widthAnchor.constraint(equalToConstant: Layout.Size.button.width)
        [
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.stackViewEdges.top),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: Layout.stackViewEdges.left),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                  constant: -Layout.stackViewEdges.bottom),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -Layout.stackViewEdges.right),

            resendWidth,
            resendButton.heightAnchor.constraint(equalToConstant: Layout.Size.button.height)
        ].activate()

        self.resendWidth = resendWidth
    }

    func populate(with data: VoucherCellData) {
        partnerIcon.image = data.partnerIcon
        voucherTitle.text = data.title
        pointsLabel.text = data.points + " - "
        dateLabel.text = data.date

        if data.showResend {
            resendWidth?.constant = 0
            resendButton.alpha = 0
        } else {
            resendWidth?.constant = Layout.Size.button.width
        }
    }

}
