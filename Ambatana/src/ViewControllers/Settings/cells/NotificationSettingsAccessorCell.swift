import LGComponents

final class NotificationSettingsAccessorCell: UITableViewCell, ReusableCell {
    
    private let label = UILabel()
    private let topSeparatorInsetView = UIView()
    private let bottomSeparatorInsetView = UIView()
    private let accessoryImageView = UIImageView()
    
    private struct Layout {
        static let accessoryHeight: CGFloat = 13
        static let accessoryWidth: CGFloat = 8
        static let separatorInsetHeight: CGFloat = 1
    }

    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI

    private func setupUI() {
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemRegularFont(size: 17)
        label.text = R.Strings.settingsNotificationsSearchAlerts
        
        topSeparatorInsetView.backgroundColor = .grayLight
        bottomSeparatorInsetView.backgroundColor = .grayLight
        
        accessoryImageView.image = R.Asset.IconsButtons.rightChevron.image
    }
    
    private func setupConstraints() {
        contentView.addSubviewsForAutoLayout([label, topSeparatorInsetView, bottomSeparatorInsetView, accessoryImageView])
        
        let constraints = [
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            label.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -Metrics.shortMargin),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.margin),
            
            topSeparatorInsetView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topSeparatorInsetView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topSeparatorInsetView.heightAnchor.constraint(equalToConstant: Layout.separatorInsetHeight),
            
            bottomSeparatorInsetView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomSeparatorInsetView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomSeparatorInsetView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSeparatorInsetView.heightAnchor.constraint(equalToConstant: Layout.separatorInsetHeight),
            
            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.margin),
            accessoryImageView.widthAnchor.constraint(equalToConstant: Layout.accessoryWidth),
            accessoryImageView.heightAnchor.constraint(equalToConstant: Layout.accessoryHeight)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupAccessibilityIds() {
        label.set(accessibilityId: .notificationSettingsCellTitle)
    }
    
    func setup(withTitle title: String) {
        label.text = title
    }
}
