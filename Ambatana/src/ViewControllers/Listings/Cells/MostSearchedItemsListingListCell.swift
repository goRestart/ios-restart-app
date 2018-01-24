//
//  MostSearchedItemsListingListCell.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 23/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class MostSearchedItemsListingListCell: UICollectionViewCell, ReusableCell {
    
    static let cellHeight: CGFloat = 230

    let trendingImageView = UIImageView()
    let titleLabel = UILabel()
    let actionBackgroundView = UIView()
    let actionLabel = UILabel()
    
    // MARK: - Lifecycle

//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)!
//    }

//    override init() {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//        setupConstraints()
//    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
        setAccessibilityIds()
    }

    
    // MARK: - UI
    
    func setup() {
        backgroundColor = UIColor.lgBlack
        
        //selectionStyle = .none
        
        trendingImageView.image = UIImage(named: "trending_feed")

        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.2
        titleLabel.text = "Most popular items this week"
        
        // TODO: Discuss with designers if this color in the specs is in the style conventions
        actionBackgroundView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
        actionBackgroundView.rounded = true

        actionLabel.font = UIFont.systemMediumFont(size: 14)
        actionLabel.textColor = UIColor.white
        actionLabel.adjustsFontSizeToFitWidth = true
        actionLabel.minimumScaleFactor = 0.2
        actionLabel.text = "See items"
    }

    private func setupConstraints() {
        let containerSubviews = [trendingImageView, titleLabel, actionBackgroundView, actionLabel]
        contentView.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: containerSubviews)
        contentView.addSubviews(containerSubviews)

        trendingImageView.layout(with: contentView)
            .centerX()
            .top(by: 30)
        trendingImageView.layout()
            .width(60)
            .height(60)

        titleLabel.layout(with: trendingImageView).below(by: Metrics.margin)
        titleLabel.layout(with: contentView)
            .leading(by: Metrics.shortMargin)
            .trailing(by: -Metrics.shortMargin)
        titleLabel.layout(with: actionBackgroundView).above(by: -Metrics.margin)
        
        actionBackgroundView.layout(with: contentView)
            .centerX()
            .leading(by: 40)
            .trailing(by: -40)
            .bottom(by: -30)
        
        actionLabel.layout(with: actionBackgroundView).fill()
    }
    
    private func setAccessibilityIds() {
//        self.accessibilityId = .collectionCell
//        imageView.accessibilityId = .collectionCellImageView
//        title.accessibilityId = .collectionCellTitle
//        exploreButton.accessibilityId =  .collectionCellExploreButton
    }
}
