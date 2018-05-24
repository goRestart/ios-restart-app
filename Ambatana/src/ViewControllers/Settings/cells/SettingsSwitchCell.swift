import UIKit
import RxSwift
import RxCocoa
import LGComponents

class SettingsSwitchCell: UITableViewCell, ReusableCell {

    private let iconImageView = UIImageView()
    private let label = UILabel()
    private let settingSwitch = UISwitch()
    
    var showBottomBorder = true

    private var lines: [CALayer] = []
    private var switchAction: ((Bool) -> Void)?
    private let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setupAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lines.forEach { $0.removeFromSuperlayer() }
        lines.removeAll()
        if showBottomBorder {
            lines.append(contentView.addBottomBorderWithWidth(LGUIKitConstants.onePixelSize, xPosition: 50, color: UIColor.lineGray))
        }
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .center

        label.font = UIFont.systemRegularFont(size: 17)
        
        settingSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    private func setupConstraints() {
        contentView.addSubviewsForAutoLayout([label, settingSwitch, iconImageView])
        
        let contentViewMargins = contentView.layoutMarginsGuide
        let constraints = [
            iconImageView.topAnchor.constraint(equalTo: contentViewMargins.topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: contentViewMargins.bottomAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: contentViewMargins.leadingAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 38),
            iconImageView.heightAnchor.constraint(equalToConstant: 38),
            
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: contentViewMargins.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentViewMargins.bottomAnchor),
            label.trailingAnchor.constraint(equalTo: contentViewMargins.trailingAnchor, constant: 64),

            settingSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingSwitch.trailingAnchor.constraint(equalTo: contentViewMargins.trailingAnchor, constant: -8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupAccessibilityIds() {
        iconImageView.set(accessibilityId: .settingsCellIcon)
        label.set(accessibilityId: .settingsCellTitle)
        settingSwitch.set(accessibilityId: .settingsCellSwitch)
    }

    func setupWithSetting(_ setting: LetGoSetting) {
        label.text = setting.title
        label.textColor = UIColor.darkGray
        iconImageView.image = setting.image
        setting.switchValue.asObservable().bind(to: settingSwitch.rx.value).disposed(by: disposeBag)
        switchAction = setting.switchAction
    }
    
    
    // MARK: - UI Actions
    
    @objc func switchValueChanged(_ sender: AnyObject) {
        switchAction?(settingSwitch.isOn)
    }
}

fileprivate extension LetGoSetting {
    var title: String {
        switch (self) {
        case .marketingNotifications:
            return R.Strings.settingsMarketingNotificationsSwitch
        default:
            return ""
        }
    }

    var image: UIImage? {
        switch (self) {
        case .marketingNotifications:
            return UIImage(named: "ic_setting_notifications")
        default:
            return nil
        }
    }

    var switchAction: ((Bool) -> Void)? {
        switch self {
        case let .marketingNotifications(_, action):
            return action
        default:
            return nil
        }
    }

    var switchValue: Variable<Bool> {
        switch self {
        case let .marketingNotifications(switchValue, _):
            return switchValue
        default:
            return Variable<Bool>(false)
        }
    }
}
