//
//  SearchAlertSwitchCell.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 23/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import LGComponents

protocol SearchAlertSwitchCellDelegate: class {
    func didEnableSearchAlertWith(id: String, enable: Bool)
}

final class SearchAlertSwitchCell: UITableViewCell, ReusableCell {
    
    private let label = UILabel()
    private let activationSwitch = UISwitch()
    private var lines: [CALayer] = []
    
    private var searchAlert: SearchAlert?
    
    weak var delegate: SearchAlertSwitchCellDelegate?
    private let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupRx()
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
    
    private func setupUI() {
        separatorInset = .zero
        
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemRegularFont(size: 17)

        activationSwitch.onTintColor = .primaryColor
    }

    private func setupRx() {
        activationSwitch.rx.value.skip(1).bind { [weak self] switchValue in
            guard let searchAlert = self?.searchAlert,
                let searchAlertId = searchAlert.objectId else { return }
            self?.delegate?.didEnableSearchAlertWith(id: searchAlertId, enable: switchValue)
        }.disposed(by: disposeBag)
    }

    private func resetUI() {
        searchAlert = nil
        label.text = nil
    }
    
    private func setupConstraints() {
        addSubviewsForAutoLayout([label, activationSwitch])
        
        let constraints = [
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.margin),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.margin),
            
            activationSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            activationSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),
            activationSwitch.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: Metrics.margin),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupAccessibilityIds() {
        label.set(accessibilityId: .notificationSettingsCellTitle)
        activationSwitch.set(accessibilityId: .notificationSettingsCellSwitch)
    }
    
    func setupWithSearchAlert(_ searchAlert: SearchAlert) {
        self.searchAlert = searchAlert
        label.text = searchAlert.query
        activationSwitch.isOn = searchAlert.enabled
        activationSwitch.isUserInteractionEnabled = !isEditing
    }
}
