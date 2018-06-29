import UIKit
import RxSwift
import RxCocoa
import LGComponents

final class NotificationSettingsSwitchCell: UITableViewCell, ReusableCell {
    
    private let label = UILabel()
    private let activationSwitch = UISwitch()
    private let topInsetView = UIView()
    
    private var switchAction: ((Bool) -> Void)?
    private let disposeBag = DisposeBag()
    
    
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
        separatorInset = .zero
        
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemRegularFont(size: 17)
        
        topInsetView.backgroundColor = .grayLight
    }
    
    private func setupConstraints() {
        addSubviewsForAutoLayout([label, activationSwitch, topInsetView])
        
        let constraints = [
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.margin),
            label.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.margin),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.margin),
            
            activationSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            activationSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),
            activationSwitch.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: Metrics.margin),
            
            topInsetView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topInsetView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topInsetView.topAnchor.constraint(equalTo: topAnchor),
            topInsetView.heightAnchor.constraint(equalToConstant: 1)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupAccessibilityIds() {
        label.set(accessibilityId: .notificationSettingsCellTitle)
        activationSwitch.set(accessibilityId: .notificationSettingsCellSwitch)
    }
    
    func setupWithSetting(_ setting: NotificationSettingsType) {
        label.text = setting.title
        
        activationSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        if let switchValue = setting.switchValue {
            switchValue.asObservable().bind(to: activationSwitch.rx.value).disposed(by: disposeBag)
            switchAction = setting.switchAction
        }
    }
    
    
    // MARK: - UI Actions
    
    @objc func switchValueChanged(_ sender: AnyObject) {
        switchAction?(activationSwitch.isOn)
    }
}

private extension NotificationSettingsType {
    var switchAction: ((Bool) -> Void)? {
        switch self {
        case let .marketing(_, action):
            return action
        default:
            return nil
        }
    }
    
    var switchValue: Variable<Bool>? {
        switch self {
        case let .marketing(switchValue, _):
            return switchValue
        default:
            return nil
        }
    }
}
