import LGCoreKit
import RxSwift
import LGComponents

final class NotificationSettingsSwitchCell: UITableViewCell, ReusableCell {
    
    static let defaultHeight: CGFloat = 80
    private enum Layout {
        static let descriptionShownBottomConstant: CGFloat = -15
        static let descriptionHiddenBottomConstant: CGFloat = 0
        static let topInsetViewHeight: CGFloat = 1
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemRegularFont(size: 17)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemRegularFont(size: 13)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let activationSwitch: UISwitch = {
        let activationSwitch = UISwitch()
        activationSwitch.backgroundColor = .white
        activationSwitch.onTintColor = UIColor.primaryColor
        return activationSwitch
    }()
    
    private var groupSetting: NotificationGroupSetting?
    private var notificationSettingCellType: NotificationSettingCellType?
    private var switchAction: ((Bool) -> Void)?
    private let disposeBag = DisposeBag()
    
    private var descriptionBottomConstraint = NSLayoutConstraint()
    private var lines: [CALayer] = []
    
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lines.forEach { $0.removeFromSuperlayer() }
        lines.removeAll()
        lines.append(contentView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
    }
    
    
    // MARK: - UI
    
    private func resetUI() {
        groupSetting = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
    }
    
    private func setupUI() {
        separatorInset = .zero
        selectionStyle = .none
    }
    
    private func setupConstraints() {
        contentView.addSubviewsForAutoLayout([titleLabel, descriptionLabel, activationSwitch])
        
        descriptionBottomConstraint = descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.margin)
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -Metrics.margin),

            activationSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            activationSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),
            activationSwitch.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Metrics.margin),
            activationSwitch.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -Metrics.margin),

            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.margin),
            descriptionBottomConstraint,
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func updateDescriptionLayout(isShown: Bool) {
        if isShown {
            descriptionBottomConstraint.constant = Layout.descriptionShownBottomConstant
        } else {
            descriptionBottomConstraint.constant = Layout.descriptionHiddenBottomConstant
        }
    }
    
    func setupWithNotificationSettingCell(_ notificationSettingCellType: NotificationSettingCellType) {
        self.notificationSettingCellType = notificationSettingCellType
        titleLabel.text = notificationSettingCellType.title
        if let description = notificationSettingCellType.description {
            descriptionLabel.text = description
            updateDescriptionLayout(isShown: true)
        } else {
            updateDescriptionLayout(isShown: false)
        }
        if let switchValue = notificationSettingCellType.switchValue {
            activationSwitch.isOn = switchValue.value
            activationSwitch.isEnabled = true
            activationSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
            switchValue.asObservable().bind(to: activationSwitch.rx.value).disposed(by: disposeBag)
            switchAction = notificationSettingCellType.switchAction
        }
    }
    
    
    // MARK: - UI Actions
    
    @objc private func switchValueChanged(_ sender: AnyObject) {
        if let notificationSettingCellType = notificationSettingCellType, notificationSettingCellType.isSwitcher {
            activationSwitch.isEnabled = false
        }
        switchAction?(activationSwitch.isOn)
    }
}
