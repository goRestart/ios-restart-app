import LGComponents

final class SettingsNotificationsSearchAlertsCell: UITableViewCell, ReusableCell {
    
    private let label = UILabel()
    private let topSeparatorInsetView = UIView()
    private let bottomSeparatorInsetView = UIView()

    
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
    }
    
    private func setupConstraints() {
        contentView.addSubviewsForAutoLayout([label, topSeparatorInsetView, bottomSeparatorInsetView])
        
        let constraints = [
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.margin),
            
            topSeparatorInsetView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topSeparatorInsetView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topSeparatorInsetView.heightAnchor.constraint(equalToConstant: 1),
            
            bottomSeparatorInsetView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomSeparatorInsetView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomSeparatorInsetView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSeparatorInsetView.heightAnchor.constraint(equalToConstant: 1)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupAccessibilityIds() {
        label.set(accessibilityId: .settingsNotificationsCellTitle)
    }
    
    func setupWithSetting(_ setting: NotificationsSetting) {
        label.text = setting.title
    }
}
