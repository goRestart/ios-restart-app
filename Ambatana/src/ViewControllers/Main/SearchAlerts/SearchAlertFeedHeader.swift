//
//  SearchAlertFeedHeader.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 19/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

protocol SearchAlertFeedHeaderDelegate: class {
    func searchAlertFeedHeaderDidEnableSearchAlert(fromEnabled: Bool)
}

final class SearchAlertFeedHeader: UIView {

    struct SearchAlertFeedHeaderLayout {
        static let imageHeight: CGFloat = 48
        static let imageWidth: CGFloat = 48
        static let textTrailing: CGFloat = 64
    }

    private let backgroundView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let activationSwitch = UISwitch()
    private let alertImageView = UIImageView()
    
    private let searchAlertCreationData: SearchAlertCreationData
    
    static let viewHeight: CGFloat = 88
    weak var delegate: SearchAlertFeedHeaderDelegate?
    
    
    // MARK: - Lifecycle
    
    init(searchAlertCreationData: SearchAlertCreationData) {
        self.searchAlertCreationData = searchAlertCreationData
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        backgroundView.backgroundColor = .white
        backgroundView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        
        titleLabel.text = searchAlertCreationData.query
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.black
        
        subtitleLabel.font = UIFont.systemRegularFont(size: 13)
        subtitleLabel.textColor = UIColor.grayDark
        subtitleLabel.text = LGLocalizedString.searchAlertsHeaderSubtitle
        
        alertImageView.image = UIImage(named: "search_alert_icon")
     
        activationSwitch.isOn = searchAlertCreationData.isEnabled
        activationSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    private func setupConstraints() {
        addSubviewsForAutoLayout([backgroundView, titleLabel, subtitleLabel, activationSwitch, alertImageView])
        
        let constraints = [
            backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.shortMargin),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.shortMargin),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.veryShortMargin),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.veryShortMargin),
            
            alertImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: Metrics.shortMargin),
            alertImageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -Metrics.shortMargin),
            alertImageView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: Metrics.shortMargin),
            alertImageView.widthAnchor.constraint(equalToConstant: SearchAlertFeedHeaderLayout.imageWidth),
            alertImageView.heightAnchor.constraint(equalToConstant: SearchAlertFeedHeaderLayout.imageHeight),
            
            titleLabel.heightAnchor.constraint(equalToConstant: Metrics.bigMargin),
            titleLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -Metrics.shortMargin),
            titleLabel.leadingAnchor.constraint(equalTo: alertImageView.trailingAnchor, constant: Metrics.veryShortMargin),
            
            subtitleLabel.heightAnchor.constraint(equalToConstant: Metrics.bigMargin),
            subtitleLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: Metrics.shortMargin),
            subtitleLabel.leadingAnchor.constraint(equalTo: alertImageView.trailingAnchor, constant: Metrics.veryShortMargin),
            
            activationSwitch.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            activationSwitch.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -Metrics.shortMargin),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor,
                                                 constant: -SearchAlertFeedHeaderLayout.textTrailing),
            subtitleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor,
                                                    constant: -SearchAlertFeedHeaderLayout.textTrailing)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    
    // MARK: - UI Actions
    
    @objc private func switchValueChanged() {
        activationSwitch.isEnabled = false
        delegate?.searchAlertFeedHeaderDidEnableSearchAlert(fromEnabled: activationSwitch.isOn)
    }
}
