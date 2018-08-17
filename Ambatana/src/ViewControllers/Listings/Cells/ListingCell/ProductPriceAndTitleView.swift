//
//  ProductPriceAndTitleView.swift
//  LetGo
//
//  Created by Haiyan Ma on 19/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

final class ProductPriceAndTitleView: UIView {
    
    struct TitleFontDescriptor: ListingTitleFontDescriptor {
        private let displayStyle: OverlayDisplayStyle
        
        init(withDisplayStyle displayStyle: OverlayDisplayStyle = .darkText) {
            self.displayStyle = displayStyle
        }
        
        var titleFont: UIFont {
            switch displayStyle {
            case .darkText:
                return ListingCellMetrics.TitleLabel.fontMedium
            case .whiteText:
                return ListingCellMetrics.TitleLabel.fontBold
            }
        }
        
        var titleColor: UIColor {
            switch displayStyle {
            case .darkText:
                return .darkGrayText
            case .whiteText:
                return .white
            }
        }
        
        var titlePrefixFont: UIFont {
            return ListingCellMetrics.TitleLabel.prefixFont
        }
        
        var titlePrefixColor: UIColor {
            switch displayStyle {
            case .darkText:
                return .blackText
            case .whiteText:
                return .white
            }
        }
    }
    
    private enum FontSize {
        static let paymentFrequency: CGFloat = 15.0
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
    
    init() {
        super.init(frame: .zero)
        alignSubViews()
        setAccessibilityIds()
        isOpaque = true
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearLabelTexts() {
        priceLabel.attributedText = nil
        priceLabel.text = nil
        titleLabel.attributedText = nil
        titleLabel.text = nil
    }
    
    
    // MARK: - Private

    private func alignSubViews() {
        addSubviewsForAutoLayout([priceLabel, titleLabel])
        layoutPriceLabel()
        layoutTitleLabel()
    }
    
    private func layoutPriceLabel() {
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
    
    func configUI(titleViewModel: ListingTitleViewModel?,
                  price: String,
                  paymentFrequency: String?,
                  style: OverlayDisplayStyle) {

        switch style {
        case .darkText:
            backgroundColor = .clear
            priceLabel.layout(with: self).top(by: ListingCellMetrics.PriceLabel.topMargin)
        case .whiteText:
            applyShadow(withOpacity: 0.5, radius: 5, color: UIColor.black.cgColor)
        }
        
        if let titleViewModel = titleViewModel {
            let fontDescriptor = TitleFontDescriptor(withDisplayStyle: style)
            if titleViewModel.shouldUseAttributedTitle {
                titleLabel.attributedText = titleViewModel.createTitleAttributedString(withFontDescriptor: fontDescriptor)
            } else {
                titleLabel.font = fontDescriptor.titleFont
                titleLabel.textColor = fontDescriptor.titleColor
                titleLabel.text = titleViewModel.title
            }
        }
        
        if let attributedPriceText = paymentFrequencyAttributedString(forPrice: price,
                                                                      paymentFrequency: paymentFrequency,
                                                                      style: style) {
            priceLabel.attributedText = attributedPriceText
        } else {
            priceLabel.text = price
            priceLabel.textColor = priceLabelColour(forDisplayStyle: style)
        }
    }
    
    private func paymentFrequencyAttributedString(forPrice price: String,
                                                  paymentFrequency: String?,
                                                  style: OverlayDisplayStyle) -> NSAttributedString? {
        guard let paymentFrequency = paymentFrequency else { return nil }
        
        let text = "\(price) \(paymentFrequency)"
        return text.bifontAttributedText(highlightedText: paymentFrequency,
                                         mainFont: ListingCellMetrics.PriceLabel.font,
                                         mainColour: priceLabelColour(forDisplayStyle: style),
                                         otherFont: UIFont.systemFont(ofSize: FontSize.paymentFrequency),
                                         otherColour: paymentFrequencyForegroundColor(forDisplayStyle: style))
    }
    
    private func paymentFrequencyForegroundColor(forDisplayStyle displayStyle: OverlayDisplayStyle) -> UIColor {
        switch displayStyle {
        case .darkText:
            return .grayDark
        case .whiteText:
            return .white
        }
    }
    
    private func priceLabelColour(forDisplayStyle displayStyle: OverlayDisplayStyle) -> UIColor {
        switch displayStyle {
        case .darkText:
            return .blackText
        case .whiteText:
            return .white
        }
    }
    
    private func setAccessibilityIds() {
        priceLabel.set(accessibilityId: .listingCellFeaturedPrice)
        titleLabel.set(accessibilityId: .listingCellFeaturedTitle)
    }
}
