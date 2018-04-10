//
//  UserVerificationNavBarView.swift
//  LetGo
//
//  Created by Isaac Roldan on 5/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

final class UserVerificationNavBarView: UIView {
    let avatarImageView = UIImageView()
    private let container = UIView()
    private let scoreLabel = UILabel()

    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: Layout.viewHeight)
    }

    private struct Layout {
        static let avatarHeight: CGFloat = 24
        static let scoreLabelLeftMargin: CGFloat = 4
        static let scoreLabelRightMargin: CGFloat = 8
        static let viewHeight: CGFloat = 32
    }

    required init() {
        super.init(frame: .zero)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadow()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewsForAutoLayout([container, avatarImageView, scoreLabel])

        avatarImageView.cornerRadius = Layout.avatarHeight / 2
        avatarImageView.contentMode = .scaleAspectFill

        scoreLabel.font = UIFont.profileKarmaOpenVerificationFont
        scoreLabel.textColor = UIColor.verificationGreen
        setupConstraints()
    }

    private func updateShadow() {
        container.setRoundedCorners()
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = .zero
        container.layer.shadowOpacity = 0.3
        container.layer.masksToBounds = false
        container.backgroundColor = .white
        container.layer.shadowRadius = 1.5
    }

    private func setupConstraints() {
        let constraints: [NSLayoutConstraint] = [
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leftAnchor.constraint(equalTo: leftAnchor),
            container.rightAnchor.constraint(equalTo: rightAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            avatarImageView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Metrics.veryShortMargin),
            avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: Layout.avatarHeight),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),
            scoreLabel.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: Layout.scoreLabelLeftMargin),
            scoreLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.scoreLabelRightMargin),
            scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
