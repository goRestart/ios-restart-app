//
//  UserVerificationSectionHeader.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

final class UserVerificationMainSectionHeader: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let imageView = UIImageView()

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
        }
    }

    required init() {
        super.init(frame: .zero)
        setupUI()
        setupAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewsForAutoLayout([titleLabel, subtitleLabel, imageView])
        backgroundColor = .white

        titleLabel.textColor = UIColor.grayDark
        titleLabel.font = UIFont.sectionTitleFont
        subtitleLabel.textColor = UIColor.grayDark
        subtitleLabel.font = UIFont.userProfileVerificationSectionSubtitleFont
        subtitleLabel.numberOfLines = 0
        imageView.image = UIImage(named: "ic_password_dark")
        imageView.contentMode = .scaleAspectFit
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 17),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: Metrics.margin),
            imageView.widthAnchor.constraint(equalToConstant: 12),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: Metrics.margin),
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metrics.shortMargin),
            subtitleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            subtitleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: Metrics.veryShortMargin),
            subtitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -Metrics.margin)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupAccessibilityIds() {
        titleLabel.set(accessibilityId: .verificationsOptionsTitle)
    }
}

final class UserVerificationSectionHeader: UIView {
    private let separator = UIView()
    private let titleLabel = UILabel()
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    required init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewsForAutoLayout([separator, titleLabel])
        backgroundColor = .white
        separator.backgroundColor = UIColor.grayLight
        titleLabel.textColor = UIColor.grayDark
        titleLabel.font = UIFont.sectionTitleFont
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            separator.leftAnchor.constraint(equalTo: leftAnchor, constant: Metrics.margin),
            separator.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.shortMargin),
            separator.rightAnchor.constraint(equalTo: rightAnchor, constant: -Metrics.bigMargin),
            separator.heightAnchor.constraint(equalToConstant: 1),
            titleLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 30),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: Metrics.margin)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
