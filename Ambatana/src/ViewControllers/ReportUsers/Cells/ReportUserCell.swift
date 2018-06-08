import UIKit
import LGComponents

final class ReportUserCell: UICollectionViewCell, ReusableCell {
    private struct Layout {
        struct Width {
            static let icon: CGFloat = 70
        }
        static let textMargin: CGFloat = 6
    }
    let reportIcon: UIImageView = {
        let imageView = UIImageView(image: R.Asset.IconsButtons.icReportScammer.image)
        imageView.contentMode = .center
        return imageView
    }()
    let reportSelected: UIImageView = {
        let imageView = UIImageView(image: R.Asset.IconsButtons.icPostOk.image)
        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        imageView.contentMode = .center
        return imageView
    }()
    let reportText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(size: 13)
        return label
    }()

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        resetUI()
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    // MARK: - Private methods

    private func setupUI() {
        reportSelected.cornerRadius = Layout.Width.icon / 2
    }

    private func setupConstraints() {
        addSubviewsForAutoLayout([reportIcon, reportSelected, reportText])
        NSLayoutConstraint.activate([
            reportIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.bigMargin),
            reportIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.bigMargin),
            reportIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.bigMargin),
            reportIcon.heightAnchor.constraint(equalToConstant: Layout.Width.icon),

            reportIcon.centerXAnchor.constraint(equalTo: reportSelected.centerXAnchor),
            reportIcon.centerYAnchor.constraint(equalTo: reportSelected.centerYAnchor),

            reportSelected.widthAnchor.constraint(equalToConstant: Layout.Width.icon),
            reportSelected.heightAnchor.constraint(equalTo: reportSelected.widthAnchor),

            reportText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.textMargin),
            reportText.topAnchor.constraint(equalTo: reportIcon.bottomAnchor, constant: Layout.textMargin),
            reportText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.textMargin),
            reportText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.textMargin)
        ])
    }

    private func resetUI() {
        reportIcon.image = nil
        reportText.text = nil
    }
}
