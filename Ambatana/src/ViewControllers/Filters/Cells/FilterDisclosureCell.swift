//
//  FilterLocationCell.swift
//  LetGo
//
//  Created by Eli Kohen Gomez on 24/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class FilterDisclosureCell: UICollectionViewCell, ReusableCell, FilterCell {
    private struct Margins {
        static let short: CGFloat = 8
        static let standard: CGFloat = 16
        static let big: CGFloat = 20
    }
    var topSeparator: UIView?
    var bottomSeparator: UIView?
    var rightSeparator: UIView?

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    fileprivate let disclosure = UIImageView(image: #imageLiteral(resourceName: "ic_disclosure"))

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

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        titleLabel.textColor = UIColor.lgBlack
        titleLabel.font = UIFont.systemFont(size: 16)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        subtitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        subtitleLabel.textColor = UIColor.filterCellsGrey
        subtitleLabel.font = UIFont.systemLightFont(size: 16)

        disclosure.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(disclosure)
        disclosure.contentMode = .center
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.short),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Margins.standard),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.short),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Margins.short),
            subtitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.short),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.short),
            disclosure.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Margins.short),
            disclosure.widthAnchor.constraint(equalToConstant: Margins.big),
            disclosure.topAnchor.constraint(equalTo: contentView.topAnchor),
            disclosure.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            disclosure.leadingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor, constant: Margins.short)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // Resets the UI to the initial state
    private func resetUI() {
        titleLabel.text = nil
        subtitleLabel.text = nil
        titleLabel.isEnabled = true
        isUserInteractionEnabled = true
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .filterDisclosureCell
        titleLabel.accessibilityId = .filterDisclosureCellTitleLabel
        subtitleLabel.accessibilityId = .filterDisclosureCellSubtitleLabel
    }
}
