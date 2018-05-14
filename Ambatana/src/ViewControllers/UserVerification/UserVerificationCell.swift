//
//  UserVerificationCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

final class UserVerificationCell: UITableViewCell, ReusableCell {
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let pointsLabel = UILabel()
    private let customAccessoryView = UIImageView()
    private let completedBadge = UIImageView()
    private var titleViewTopConstraint: NSLayoutConstraint?
    private var eventCountLabel = UILabel()

    private struct Layout {
        static let logoImageHeight: CGFloat = 40
        static let badgeHeight: CGFloat = 26
        static let eventCountLabelCenterOffset: CGFloat = 2
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([logoImageView, titleLabel, subtitleLabel, pointsLabel,
                                              customAccessoryView, completedBadge, eventCountLabel])

        logoImageView.contentMode = .scaleAspectFit
        titleLabel.font = .verificationItemTitle
        titleLabel.textColor = .lgBlack
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitleLabel.font = .mediumBodyFont
        subtitleLabel.textColor = .grayDisclaimerText
        subtitleLabel.numberOfLines = 0
        pointsLabel.font = .verificationItemTitle
        pointsLabel.textColor = .verificationPoints
        pointsLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        eventCountLabel.font = .verificationEventCountFont
        eventCountLabel.textColor = .grayDark
        eventCountLabel.textAlignment = .center
        eventCountLabel.isHidden = true
        completedBadge.image = UIImage(named: "verify_check")
        customAccessoryView.image = UIImage(named: "right_chevron")
        setupConstraints()
    }

    private func setupConstraints() {
        let contraints: [NSLayoutConstraint] = [
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Metrics.margin),
            logoImageView.heightAnchor.constraint(equalToConstant: Layout.logoImageHeight),
            logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor),
            titleLabel.leftAnchor.constraint(equalTo: logoImageView.rightAnchor, constant: Metrics.margin),
            titleLabel.rightAnchor.constraint(lessThanOrEqualTo: pointsLabel.leftAnchor, constant: -Metrics.shortMargin),
            subtitleLabel.leftAnchor.constraint(equalTo: logoImageView.rightAnchor, constant: Metrics.margin),
            subtitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Metrics.veryBigMargin),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metrics.veryShortMargin),
            customAccessoryView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customAccessoryView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Metrics.margin),
            pointsLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            pointsLabel.rightAnchor.constraint(equalTo: customAccessoryView.leftAnchor, constant: -Metrics.margin),
            completedBadge.heightAnchor.constraint(equalToConstant: Layout.badgeHeight),
            completedBadge.widthAnchor.constraint(equalTo: completedBadge.heightAnchor),
            completedBadge.topAnchor.constraint(equalTo: logoImageView.topAnchor, constant: Metrics.bigMargin),
            completedBadge.leftAnchor.constraint(equalTo: logoImageView.leftAnchor, constant: Metrics.bigMargin),
            eventCountLabel.centerXAnchor.constraint(equalTo: completedBadge.centerXAnchor),
            eventCountLabel.centerYAnchor.constraint(equalTo: completedBadge.centerYAnchor,
                                                     constant: -Layout.eventCountLabelCenterOffset)
        ]

        NSLayoutConstraint.activate(contraints)

        titleViewTopConstraint = titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.bigMargin)
        titleViewTopConstraint?.isActive = true
    }

    func configure(with item: UserVerificationItem) {
        logoImageView.image = item.image
        titleLabel.text = item.title
        pointsLabel.text = item.pointsValue
        customAccessoryView.isHidden = !item.showsAccessoryView
        selectionStyle = item.canBeSelected ? .default : .none
        setCompleted(completed: item.completed, eventCount: item.eventCountString)
        subtitleLabel.text = item.subtitle
        titleViewTopConstraint?.constant = item.subtitle == nil ? Metrics.bigMargin : Metrics.margin
    }

    private func setCompleted(completed: Bool, eventCount: String?) {
        logoImageView.alpha = completed ? 0.30 : 1
        titleLabel.alpha = completed ? 0.30 : 1
        pointsLabel.alpha = completed ? 0.30 : 1
        customAccessoryView.alpha = completed ? 0.30 : 1
        completedBadge.isHidden = !completed && eventCount == nil
        completedBadge.image = eventCount == nil ? #imageLiteral(resourceName: "verify_check") : #imageLiteral(resourceName: "oval")
        eventCountLabel.isHidden = eventCount == nil
        eventCountLabel.text = eventCount
    }
}
