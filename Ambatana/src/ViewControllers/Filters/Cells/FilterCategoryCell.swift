//
//  FilterCategoryCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGComponents

class FilterCategoryCell: UICollectionViewCell, ReusableCell, FilterCell {
    private struct Margins {
        static let titleTrailing: CGFloat = 8
    }
    var topSeparator: UIView?
    var bottomSeparator: UIView?
    var rightSeparator: UIView?

    let categoryIcon = UIImageView()
    let titleLabel = UILabel()

    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.resetUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        contentView.backgroundColor = .white
        addTopSeparator(toContainerView: contentView)
        addRightSeparator(toContainerView: contentView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(size: 16)
        titleLabel.textColor = UIColor.lgBlack
        
        categoryIcon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryIcon)
        categoryIcon.clipsToBounds = true

        let constraints = [
            categoryIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.shortMargin),
            categoryIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.shortMargin),
            categoryIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.shortMargin),
            categoryIcon.widthAnchor.constraint(equalTo: categoryIcon.heightAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: categoryIcon.trailingAnchor, constant: Metrics.shortMargin),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Margins.titleTrailing)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        categoryIcon.image = nil
        titleLabel.text = ""
        rightSeparator?.isHidden = true
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .filterCategoryCell)
        categoryIcon.set(accessibilityId: .filtersCollectionView)
        titleLabel.set(accessibilityId: .filtersSaveFiltersButton)
    }
}
