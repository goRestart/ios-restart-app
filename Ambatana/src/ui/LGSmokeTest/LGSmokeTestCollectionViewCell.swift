
import Foundation
import LGComponents

final class LGSmokeTestCollectionViewCell: UICollectionViewCell, ReusableCell {
    
    private enum Layout {
        
        static var verticalSpacing: CGFloat {
            guard DeviceFamily.current.isWiderOrEqualThan(.iPhone5) else { return 3 }
            guard DeviceFamily.current.isWiderOrEqualThan(.iPhone6) else { return 6 }
            return 16
        }
        static let imageHeightMultiplier: CGFloat = DeviceFamily.current.isWiderOrEqualThan(.iPhone5) ? 0.5 : 0.3
        static let cornerRadius: CGFloat = 8.0
        static let titleLabelTopInset: CGFloat = verticalSpacing
        static let subtitleLabelTopInset: CGFloat = verticalSpacing
        static let descriptionLabelTopInset: CGFloat = verticalSpacing
        static let descriptionLabelBottomInset: CGFloat = 26.0
        static let horizontalInset: CGFloat = 8.0
        static let descriptionLabelHorizontalInset: CGFloat = 16.0
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .blackText
        label.font = UIFont.systemBoldFont(size: 36)
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .blackText
        label.font = UIFont.systemBoldFont(size: 28)
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .grayDark
        label.font = UIFont.systemFont(size: 16)
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let descriptionStringAttributes: [NSAttributedStringKey: Any] = {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10.0
        paragraphStyle.alignment = .center
        
        return [.font: UIFont.systemFont(size: 16),
                .foregroundColor: UIColor.grayDark,
                .paragraphStyle: paragraphStyle]
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        cornerRadius = Layout.cornerRadius
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
    }
    
    private func setupLayout() {
        
        contentView.addSubviewsForAutoLayout([
            imageView,
            titleLabel,
            subtitleLabel,
            descriptionLabel
            ])
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.safeTopAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor,
                                              multiplier: Layout.imageHeightMultiplier),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                constant: Layout.horizontalInset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                 constant: -Layout.horizontalInset),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,
                                            constant: Layout.titleLabelTopInset),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                   constant: Layout.horizontalInset),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -Layout.horizontalInset),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                               constant: Layout.subtitleLabelTopInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                      constant: Layout.descriptionLabelHorizontalInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                       constant: -Layout.descriptionLabelHorizontalInset),
            descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor,
                                                  constant: Layout.descriptionLabelTopInset),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.safeBottomAnchor,
                                                     constant: Layout.descriptionLabelBottomInset)
            ])
    }
    
    func populate(with page: LGSmokeTestPage) {
        titleLabel.text = page.title
        subtitleLabel.text = page.subtitle
        imageView.image = page.image
        
        applyDescriptionText(forDescription: page.description)
    }
    
    private func applyDescriptionText(forDescription description: String?) {
        guard let description = description else {
            descriptionLabel.attributedText = nil
            return
        }

        let attributedString = NSAttributedString(string: description,
                                                  attributes: descriptionStringAttributes)
        descriptionLabel.attributedText = attributedString
    }
}
