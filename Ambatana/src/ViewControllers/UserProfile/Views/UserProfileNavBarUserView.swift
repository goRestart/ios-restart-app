//
//  UserProfileNavBarUserView.swift
//  LetGo
//
//  Created by Sergi Gracia on 02/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

final class UserProfileNavBarUserView: UIView {

    let userNameLabel = UILabel()
    let userRatingView = RatingView(layout: .mini)

    private struct Layout {
        static let margin: CGFloat = 3
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    private func setupUI() {
        addSubviewsForAutoLayout([userNameLabel, userRatingView])

        userNameLabel.textAlignment = .center
        userNameLabel.font = .boldBarButtonFont
        userNameLabel.textColor = .lgBlack

        setupConstraints()
    }

    private func setupConstraints() {
        userRatingView.setContentHuggingPriority(.required, for: .vertical)

        let constraints = [
            userNameLabel.topAnchor.constraint(equalTo: topAnchor),
            userNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            userRatingView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: Layout.margin),
            userRatingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            userRatingView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
