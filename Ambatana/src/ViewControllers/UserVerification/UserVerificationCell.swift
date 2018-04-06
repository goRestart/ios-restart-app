//
//  UserVerificationCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class UserVerificationCell: UITableViewCell, ReusableCell {
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let pointsLabel = UILabel()
    private let customAccessoryView = UIImageView()
    private let completedBadge = UIImageView()
    private var titleViewTopConstraint: NSLayoutConstraint?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubviewsForAutoLayout([logoImageView, titleLabel, subtitleLabel,
                                              pointsLabel, customAccessoryView, completedBadge])

        logoImageView.contentMode = .scaleAspectFit
        titleLabel.font = UIFont.verificationItemTitle
        titleLabel.textColor = UIColor.lgBlack
        subtitleLabel.font = UIFont.mediumBodyFont
        subtitleLabel.textColor = UIColor.grayDisclaimerText
        pointsLabel.font = UIFont.verificationItemTitle
        pointsLabel.textColor = UIColor.verificationPoints
        completedBadge.image = UIImage(named: "verify_check")
        customAccessoryView.image = UIImage(named: "right_chevron")
        setupConstraints()
    }

    private func setupConstraints() {
        let contraints: [NSLayoutConstraint] = [
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            logoImageView.widthAnchor.constraint(equalTo: logoImageView.heightAnchor),
            titleLabel.leftAnchor.constraint(equalTo: logoImageView.rightAnchor, constant: 15),
            subtitleLabel.leftAnchor.constraint(equalTo: logoImageView.rightAnchor, constant: 15),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            customAccessoryView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customAccessoryView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15),
            pointsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pointsLabel.rightAnchor.constraint(equalTo: customAccessoryView.leftAnchor, constant: -15),
            completedBadge.heightAnchor.constraint(equalToConstant: 24),
            completedBadge.widthAnchor.constraint(equalTo: completedBadge.heightAnchor),
            completedBadge.topAnchor.constraint(equalTo: logoImageView.topAnchor, constant: 20),
            completedBadge.leftAnchor.constraint(equalTo: logoImageView.leftAnchor, constant: 20)
        ]

        NSLayoutConstraint.activate(contraints)

        titleViewTopConstraint = titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 21)
        titleViewTopConstraint?.isActive = true
    }

    func configure(with item: UserVerificationItem) {
        logoImageView.image = item.image
        titleLabel.text = item.title
        pointsLabel.text = item.pointsValue
        customAccessoryView.isHidden = !item.showsAccessoryView
        selectionStyle = item.canBeSelected ? .default : .none
        setCompleted(completed: item.completed)
        subtitleLabel.text = item.subtitle
        titleViewTopConstraint?.constant = item.subtitle == nil ? 21 : 15
    }

    private func setCompleted(completed: Bool) {
        logoImageView.alpha = completed ? 0.30 : 1
        titleLabel.alpha = completed ? 0.30 : 1
        pointsLabel.alpha = completed ? 0.30 : 1
        customAccessoryView.alpha = completed ? 0.30 : 1
        completedBadge.isHidden = !completed
    }
}
