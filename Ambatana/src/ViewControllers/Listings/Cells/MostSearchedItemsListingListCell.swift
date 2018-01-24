//
//  MostSearchedItemsListingListCell.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 23/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class MostSearchedItemsListingListCell: UICollectionViewCell, ReusableCell {
    
    static let height: CGFloat = 230

    let corneredView = UIView()
    let trendingImageView = UIImageView()
    let titleLabel = UILabel()
    let actionBackgroundView = UIView()
    let actionLabel = UILabel()
    
    
    // MARK: - Lifecycle

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        actionBackgroundView.rounded = true
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        corneredView.backgroundColor = UIColor.lgBlack
        
        corneredView.layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        
        trendingImageView.image = UIImage(named: "trending_feed")

        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.2
        titleLabel.text = LGLocalizedString.trendingItemsCardTitle
        
        actionBackgroundView.backgroundColor = UIColor.grayDark
        actionBackgroundView.rounded = true

        actionLabel.font = UIFont.systemMediumFont(size: 14)
        actionLabel.textColor = UIColor.white
        actionLabel.textAlignment = .center
        actionLabel.adjustsFontSizeToFitWidth = true
        actionLabel.minimumScaleFactor = 0.2
        actionLabel.text = LGLocalizedString.trendingItemsCardAction
    }

    private func setupConstraints() {
        let containerSubviews = [corneredView, trendingImageView, titleLabel, actionBackgroundView, actionLabel]
        contentView.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: containerSubviews)
        contentView.addSubviews(containerSubviews)

        corneredView.layout(with: contentView).fill()
        
        let cardVerticalMargin: CGFloat = 30
        
        trendingImageView.layout(with: contentView)
            .centerX()
            .top(by: cardVerticalMargin)
        trendingImageView.layout()
            .width(60)
            .height(60)

        titleLabel.layout(with: trendingImageView).below(by: Metrics.margin)
        titleLabel.layout(with: contentView)
            .leading(by: Metrics.shortMargin)
            .trailing(by: -Metrics.shortMargin)
        titleLabel.layout(with: actionBackgroundView).above(by: -Metrics.margin)
        
        let actionBackgroundViewLateralMargin = contentView.width/5
        actionBackgroundView.layout(with: contentView)
            .centerX()
            .leading(by: actionBackgroundViewLateralMargin)
            .trailing(by: -actionBackgroundViewLateralMargin)
            .bottom(by: -cardVerticalMargin)
        actionBackgroundView.layout().height(32)
        
        actionLabel.layout(with: actionBackgroundView).fill()
    }
}
