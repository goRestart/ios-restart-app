//
//  MostSearchedItemsListHeader.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 17/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

class MostSearchedItemsListHeader: UIView {
    
    static let viewHeight: CGFloat = 180
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let subtitleView = UIView()
    private let subtitleImageView = UIImageView()
    private let subtitleLabel = UILabel()
    
    
    // MARK: - Lifecycle
    
    init(title: String) {
        super.init(frame: CGRect.zero)
        setupUI(title: title)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI(title: String) {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 2
        titleLabel.text = title
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.2
        
        descriptionLabel.font = UIFont.systemRegularFont(size: 17)
        descriptionLabel.textColor = UIColor.darkGrayText
        descriptionLabel.numberOfLines = 2
        descriptionLabel.text = LGLocalizedString.trendingItemsViewSubtitle
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.minimumScaleFactor = 0.2
        
        subtitleImageView.image = UIImage(named: "ic_search")
        
        subtitleLabel.font = UIFont.systemMediumFont(size: 13)
        subtitleLabel.textColor = UIColor.grayText
        subtitleLabel.text = LGLocalizedString.trendingItemsViewNumberOfSearchesTitle
    }
    
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        let containerSubviews = [titleLabel, descriptionLabel, subtitleView]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: containerSubviews)
        addSubviews(containerSubviews)
        
        let subtitleViews = [subtitleImageView, subtitleLabel]
        subtitleView.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subtitleViews)
        subtitleView.addSubviews(subtitleViews)
        
        titleLabel.layout(with: self).fillHorizontal(by: Metrics.bigMargin)
        titleLabel.layout(with: self).below(by: Metrics.bigMargin)
        titleLabel.layout().height(56)

        descriptionLabel.layout(with: self).fillHorizontal(by: Metrics.bigMargin)
        descriptionLabel.layout(with: titleLabel).below(by: Metrics.margin)
        descriptionLabel.layout().height(60)
        
        subtitleView.layout(with: self).fillHorizontal()
        subtitleView.layout(with: descriptionLabel).below(by: Metrics.margin)
        subtitleView.layout().height(15)
        
        subtitleImageView.layout(with: subtitleView)
            .fillVertical()
            .leading(by: Metrics.bigMargin)
        subtitleImageView.layout()
            .width(15)
            .height(15)
        
        subtitleLabel.layout(with: subtitleView)
            .fillVertical()
            .trailing(by: Metrics.bigMargin)
        subtitleLabel.layout(with: subtitleImageView).toLeft(by: Metrics.margin)
    }
}
