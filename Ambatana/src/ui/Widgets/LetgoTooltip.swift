//
//  LetgoTooltip.swift
//  LetGo
//
//  Created by Isaac Roldan on 17/5/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol LetgoTooltipDelegate: class {
    func didTapTooltip()
}

final class LetgoTooltip: UIView {
    private let container = UIView()
    private let peakImageView = UIImageView()
    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView()

    private var peakOnTopConstraint: NSLayoutConstraint!
    private var peakOnBottomConstraint: NSLayoutConstraint!
    private var peakCenterConstraint: NSLayoutConstraint!
    weak var delegate: LetgoTooltipDelegate?

    private var topPeakImage: UIImage {
        return #imageLiteral(resourceName: "tooltip_peak_center_black").rotatedImage().rotatedImage().withRenderingMode(.alwaysTemplate)
    }

    private var bottomPeakImage: UIImage {
        return #imageLiteral(resourceName: "tooltip_peak_center_black").withRenderingMode(.alwaysTemplate)
    }

    var peakOnTop: Bool = true {
        didSet {
            peakOnTopConstraint.isActive = peakOnTop
            peakOnBottomConstraint.isActive = !peakOnTop
            peakImageView.image = peakOnTop ? topPeakImage : bottomPeakImage
            layoutIfNeeded()
        }
    }

    var peakOffsetFromLeft: CGFloat = 0 {
        didSet {
            self.peakCenterConstraint.constant = peakOffsetFromLeft
            self.peakCenterConstraint.isActive = true
            layoutIfNeeded()
        }
    }

    struct Layout {
        static let peakHeight: CGFloat = 8
        static let peakWidth: CGFloat = 18
        static let maxWidth: CGFloat = 250
        static let chevronHeight: CGFloat = 13
        static let chevronWidth: CGFloat = 8
    }

    var message: String = "" {
        didSet {
            titleLabel.text = message
        }
    }

    init() {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubviewsForAutoLayout([container, peakImageView, titleLabel, chevronImageView])
        container.backgroundColor = .lgBlack
        container.layer.cornerRadius = 10

        titleLabel.font = UIFont.tooltipMessageFont
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.text = ""

        chevronImageView.image = #imageLiteral(resourceName: "ml_icon_chevron")
        peakImageView.tintColor = .lgBlack

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapTooltip))
        container.addGestureRecognizer(tap)
    }

    @objc func didTapTooltip() {
        delegate?.didTapTooltip()
    }

    func setupConstraints() {
        var constraints: [NSLayoutConstraint] = [
            container.widthAnchor.constraint(lessThanOrEqualToConstant: Layout.maxWidth),
            container.topAnchor.constraint(equalTo: topAnchor, constant: Layout.peakHeight),
            container.leftAnchor.constraint(equalTo: leftAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.peakHeight),
            container.rightAnchor.constraint(equalTo: rightAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: Metrics.margin),
            titleLabel.leftAnchor.constraint(equalTo: container.leftAnchor, constant: Metrics.margin),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Metrics.margin),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: Metrics.veryShortMargin),
            chevronImageView.widthAnchor.constraint(equalToConstant: Layout.chevronWidth),
            chevronImageView.heightAnchor.constraint(equalToConstant: Layout.chevronHeight),
            chevronImageView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -Metrics.margin),
            peakImageView.heightAnchor.constraint(equalToConstant: Layout.peakHeight),
            peakImageView.widthAnchor.constraint(equalToConstant: Layout.peakWidth)
        ]

        peakOnTopConstraint = peakImageView.bottomAnchor.constraint(equalTo: container.topAnchor)
        peakOnBottomConstraint = peakImageView.topAnchor.constraint(equalTo: container.bottomAnchor)
        peakCenterConstraint = peakImageView.centerXAnchor.constraint(equalTo: leftAnchor, constant: 0)

        constraints.append(contentsOf: [peakOnTopConstraint, peakCenterConstraint])
        NSLayoutConstraint.activate(constraints)
    }
}
