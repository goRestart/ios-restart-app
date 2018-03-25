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
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ListingCellMetrics.TitleLabel.fontMedium
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.spacing = 0
        return stackView
    }()

    init() {
        super.init(frame: .zero)
        setupStackView()
        setAccessibilityIds()
    }

    func update(with price: String, title: String?, textStyle: DisplayStyle) {
        priceLabel.text = price
        titleLabel.text = title
        configTextStyle(textStyle)
    }
    
    func clearLabelTexts() {
        priceLabel.text = nil
        titleLabel.text = nil
    }
    
    // MARK: - Private

    private func setupStackView() {
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(titleLabel)
        addSubviewForAutoLayout(stackView)
        stackView.layout(with: self)
            .top(by: ListingCellMetrics.PriceLabel.topMargin)
            .fillHorizontal(by: ListingCellMetrics.sideMargin)
            .bottom(by: -ListingCellMetrics.TitleLabel.bottomMargin)
        NSLayoutConstraint.activate([
            priceLabel.heightAnchor.constraint(equalToConstant: ListingCellMetrics.PriceLabel.height),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1.0)
        ])
    }
    
    private func configTextStyle(_ style: DisplayStyle) {
        switch style {
        case .darkText:
            priceLabel.textColor = UIColor.blackText
            titleLabel.textColor = .darkGrayText
            backgroundColor = .clear
            titleLabel.font = ListingCellMetrics.TitleLabel.fontMedium
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
