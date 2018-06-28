//
//  FilterHeaderCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGComponents

class FilterHeaderCell: UICollectionReusableView, FilterCell, ReusableCell {
    var topSeparator: UIView?
    var bottomSeparator: UIView?
    var rightSeparator: UIView?

    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        resetUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        addTopSeparator(toContainerView: self)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.margin),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.margin),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.shortMargin),
            titleLabel.heightAnchor.constraint(equalToConstant: Metrics.margin)
        ]
        NSLayoutConstraint.activate(constraints)
        titleLabel.font = UIFont.systemLightFont(size: 13)
        titleLabel.textColor = UIColor.filterCellsGrey
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        titleLabel.text = ""
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .filterHeaderCell)
        titleLabel.set(accessibilityId: .filterHeaderCellTitleLabel)
    }
}
