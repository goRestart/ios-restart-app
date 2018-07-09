import Foundation
import LGComponents

final class ReportOptionCell: UITableViewCell, ReusableCell {

    private enum Layout {
        static let iconSize: CGFloat = 38
        static let accessoryHeight: CGFloat = 13
        static let accessoryWidth: CGFloat = 8
        static let labelMargin: CGFloat = 19
        static let labelRightMargin: CGFloat = 38
        static let labelLeftBigMargin: CGFloat = 68
        static let labelLeftSmallMargin: CGFloat = 15
        static let checkmarkHeight: CGFloat = 15
        static let checkmarkWidth: CGFloat = 20
    }

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.reportCellTitleFont
        label.textColor = UIColor.lgBlack
        return label
    }()

    private let accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.Asset.IconsButtons.rightChevron.image
        return imageView
    }()

    private let selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.Asset.Reporting.icCheck.image
        imageView.isHidden = true
        return imageView
    }()

    var shouldShowIcon: Bool = true {
        didSet {
            iconImageView.isHidden = !shouldShowIcon
            titleLabelLeftConstraint?.constant = shouldShowIcon ? Layout.labelLeftBigMargin : Layout.labelLeftSmallMargin
        }
    }

    private var titleLabelLeftConstraint: NSLayoutConstraint?
    private var canShowCheckMark: Bool = true

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with option: ReportOption) {
        titleLabel.text = option.type.text
        iconImageView.image = option.type.icon
        accessoryImageView.isHidden = option.childOptions == nil
        canShowCheckMark = option.childOptions == nil
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([iconImageView, titleLabel, accessoryImageView, selectedImageView])
        setupConstraints()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        guard canShowCheckMark else { return }
        super.setSelected(selected, animated: true)
        selectedImageView.isHidden = !selected
    }

    override func prepareForReuse() {
        accessoryImageView.isHidden = true
        selectedImageView.isHidden = !isSelected
    }

    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = [
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Metrics.margin),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize),
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.labelMargin),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.labelMargin),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: Layout.labelRightMargin),
            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Metrics.margin),
            accessoryImageView.heightAnchor.constraint(equalToConstant: Layout.accessoryHeight),
            accessoryImageView.widthAnchor.constraint(equalToConstant: Layout.accessoryWidth),
            selectedImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Metrics.margin),
            selectedImageView.heightAnchor.constraint(equalToConstant: Layout.checkmarkHeight),
            selectedImageView.widthAnchor.constraint(equalToConstant: Layout.checkmarkWidth)
        ]

        let labelLeft = titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Layout.labelLeftBigMargin)
        titleLabelLeftConstraint = labelLeft

        constraints.append(labelLeft)
        NSLayoutConstraint.activate(constraints)
    }
}
