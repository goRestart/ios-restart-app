//
//  UserVerificationNavBarView.swift
//  LetGo
//
//  Created by Isaac Roldan on 5/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGComponents

final class UserVerificationNavBarView: UIView {
    private let avatarImageView = UIImageView()
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

    private enum Layout {
        static let avatarSize: CGFloat = 24
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

    func setAvatar(_ url: URL?, placeholderImage: UIImage?) {
        if let url = url {
            avatarImageView.lg_setImageWithURL(url)
        } else {
            avatarImageView.image = placeholderImage
        }
    }


    private func setupUI() {
        addSubviewForAutoLayout(container)
        container.addSubviewsForAutoLayout([avatarImageView, scoreLabel])

        avatarImageView.cornerRadius = Layout.avatarSize / 2
        avatarImageView.contentMode = .scaleAspectFill

        scoreLabel.font = UIFont.profileKarmaOpenVerificationFont
        scoreLabel.textColor = UIColor.verificationGreen
        scoreLabel.textAlignment = .right
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
            avatarImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: Layout.avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: Layout.avatarSize),
            scoreLabel.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: Layout.scoreLabelLeftMargin),
            scoreLabel.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Layout.scoreLabelRightMargin),
            scoreLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
