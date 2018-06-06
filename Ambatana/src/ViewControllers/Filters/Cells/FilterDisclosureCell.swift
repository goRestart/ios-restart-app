import UIKit
import LGComponents

class FilterDisclosureCell: UICollectionViewCell, ReusableCell, FilterCell {
    private struct Margins {
        static let short: CGFloat = 8
        static let standard: CGFloat = 16
        static let big: CGFloat = 20
    }
    var topSeparator: UIView?
    var bottomSeparator: UIView?
    var rightSeparator: UIView?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lgBlack
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.font = UIFont.systemFont(size: 16)
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.textColor = UIColor.filterCellsGrey
        label.font = UIFont.systemLightFont(size: 16)
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    
    fileprivate let disclosure: UIImageView = {
        let imageView = UIImageView(image: R.Asset.IconsButtons.icDisclosure.image)
        imageView.contentMode = .center

        return imageView
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.resetUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    // MARK: - Private methods

    private func setupUI() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubviewForAutoLayout(titleLabel)
        contentView.addSubviewForAutoLayout(subtitleLabel)
        contentView.addSubviewForAutoLayout(disclosure)
    }
    
    private func setupConstraints() {
        contentView.backgroundColor = .white
        addTopSeparator(toContainerView: contentView)
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.short),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Margins.standard),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.short),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Margins.short),
            subtitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.short),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.short),
            disclosure.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Margins.short),
            disclosure.widthAnchor.constraint(equalToConstant: Margins.big),
            disclosure.topAnchor.constraint(equalTo: contentView.topAnchor),
            disclosure.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            disclosure.leadingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor, constant: Margins.short)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // Resets the UI to the initial state
    private func resetUI() {
        titleLabel.text = nil
        subtitleLabel.text = nil
        titleLabel.isEnabled = true
        isUserInteractionEnabled = true
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .filterDisclosureCell)
        titleLabel.set(accessibilityId: .filterDisclosureCellTitleLabel)
        subtitleLabel.set(accessibilityId: .filterDisclosureCellSubtitleLabel)
    }
}
