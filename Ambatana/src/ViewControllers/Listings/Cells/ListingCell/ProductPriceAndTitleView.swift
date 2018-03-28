//
//  ProductPriceAndTitleView.swift
//  LetGo
//
//  Created by Haiyan Ma on 19/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

final class ProductPriceAndTitleView: UIView {
    
    enum DisplayStyle {
        case whiteText, darkText
    }
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = ListingCellMetrics.PriceLabel.font
        label.numberOfLines = 1
        label.textAlignment = .left
        label.setContentHuggingPriority(.required, for: .vertical)
        label.clipsToBounds = true
        label.isOpaque = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ListingCellMetrics.TitleLabel.fontMedium
        label.numberOfLines = 2
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.required, for: .vertical)
        label.clipsToBounds = true
        label.isOpaque = true
        return label
    }()
    
    init(textStyle: DisplayStyle = .darkText) {
        super.init(frame: .zero)
        alignSubViews(style: textStyle)
        setAccessibilityIds()
        isOpaque = true
        clipsToBounds = true
    }
    
    func clearLabelTexts() {
        priceLabel.text = nil
        titleLabel.text = nil
    }
    
    
    // MARK: - Private

    private func alignSubViews(style: DisplayStyle) {
        addSubviewsForAutoLayout([priceLabel, titleLabel])
        layoutPriceLabel(style: style)
        layoutTitleLabel()
    }
    
    private func layoutPriceLabel(style: DisplayStyle) {
        priceLabel.layout(with: self)
            .fillHorizontal(by: ListingCellMetrics.sideMargin)
        
        NSLayoutConstraint.activate([
            priceLabel.heightAnchor.constraint(equalToConstant: ListingCellMetrics.PriceLabel.height)
        ])
    }
    
    private func layoutTitleLabel() {
        titleLabel.layout(with: self)
            .fillHorizontal(by: ListingCellMetrics.sideMargin)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -ListingCellMetrics.TitleLabel.bottomMargin)
        ])
    }
    
    func configUI(title: String?, price: String, style: DisplayStyle) {
        priceLabel.text = price
        titleLabel.text = title
        switch style {
        case .darkText:
            priceLabel.textColor = UIColor.blackText
            titleLabel.textColor = .darkGrayText
            backgroundColor = .clear
            titleLabel.font = ListingCellMetrics.TitleLabel.fontMedium
            priceLabel.layout(with: self).top(by: ListingCellMetrics.PriceLabel.topMargin)
        case .whiteText:
            titleLabel.textColor = .white
            priceLabel.textColor = .white
            titleLabel.font = ListingCellMetrics.TitleLabel.fontBold
            applyShadow(withOpacity: 0.5, radius: 5, color: UIColor.black.cgColor)
        }
    }
    
    private func setAccessibilityIds() {
        priceLabel.set(accessibilityId: .listingCellFeaturedPrice)
        titleLabel.set(accessibilityId: .listingCellFeaturedTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
