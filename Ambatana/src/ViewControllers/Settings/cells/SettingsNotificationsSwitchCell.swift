//
//  SettingsNotificationsSwitchCell.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 17/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import LGComponents

final class SettingsNotificationsSwitchCell: UITableViewCell, ReusableCell {
    
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
        label.set(accessibilityId: .settingsNotificationsCellTitle)
        activationSwitch.set(accessibilityId: .settingsNotificationsCellSwitch)
    }
    
    func setupWithSetting(_ setting: NotificationsSetting) {
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

private extension NotificationsSetting {
    var switchAction: ((Bool) -> Void)? {
        switch self {
        case let .marketingNotifications(_, action):
            return action
        default:
            return nil
        }
    }
    
    var switchValue: Variable<Bool>? {
        switch self {
        case let .marketingNotifications(switchValue, _):
            return switchValue
        default:
            return nil
        }
    }
}
