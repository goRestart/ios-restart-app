import LGComponents

final class NotificationSettingsAccessorCell: UITableViewCell, ReusableCell {
    
    private let label = UILabel()
    private let accessoryImageView = UIImageView()
    private var lines: [CALayer] = []
    
    static let defaultHeight: CGFloat = 50
    private struct Layout {
        static let accessoryHeight: CGFloat = 13
        static let accessoryWidth: CGFloat = 8
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lines.forEach { $0.removeFromSuperlayer() }
        lines.removeAll()
        lines.append(contentView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
    }
    
    
    // MARK: - UI

    private func setupUI() {
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemRegularFont(size: 17)
        label.text = R.Strings.settingsNotificationsSearchAlerts
        
        accessoryImageView.image = R.Asset.IconsButtons.rightChevron.image
    }
    
    private func setupConstraints() {
        contentView.addSubviewsForAutoLayout([label, accessoryImageView])
        
        let constraints = [
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            label.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -Metrics.shortMargin),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.margin),
            
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
