//
//  RateBuyersView.swift
//  LetGo
//
//  Created by Eli Kohen on 03/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

enum SourceRateBuyers {
    case markAsSold
    case rateBuyer
}

class RateBuyersHeader: UIView {

    private let imageMargin: CGFloat = 10
    private let imageDiameter: CGFloat = 110
    private let textsHMargin: CGFloat = 40

    let header = UIView()
    private let source: SourceRateBuyers?


    // MARK: - Lifecycle

    init(source: SourceRateBuyers?) {
        self.source = source
        super.init(frame: CGRect.zero)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setupViews() {
        setupHeaderViews()
        backgroundColor = UIColor.grayBackground
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [header])
        addSubviews([header])
        header.layout(with: self).leading().trailing().top().bottom()
    }

    private func setupHeaderViews() {
        let iconImage = UIImageView()
        let titleLabel = UILabel()
        let messageLabel = UILabel()

        iconImage.clipsToBounds = true
        iconImage.contentMode = .scaleAspectFit
        iconImage.image = #imageLiteral(resourceName: "emoji_congrats")
        titleLabel.textColor = UIColor.lgBlack
        titleLabel.font = UIFont.systemMediumFont(size: 17)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.text = setTitle().uppercase
        messageLabel.textColor = UIColor.darkGrayText
        messageLabel.font = UIFont.mediumBodyFont
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.text = setSubtitle()
        
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [iconImage, titleLabel, messageLabel])
        header.addSubviews([iconImage, titleLabel, messageLabel])
        
        iconImage.layout(with: header).top(by: imageMargin).centerX()
        iconImage.layout().width(imageDiameter).widthProportionalToHeight()
        titleLabel.layout(with: header).leading(by: textsHMargin).trailing(by: -textsHMargin)
        titleLabel.layout(with: iconImage).below(by: Metrics.margin)
        messageLabel.layout(with: header).leading(by: textsHMargin).trailing(by: -textsHMargin)
        messageLabel.layout(with: titleLabel).below(by: Metrics.veryShortMargin)
        messageLabel.layout(with: header).bottom(by: -Metrics.veryBigMargin)
        
    }
    
    private func setTitle() -> String {
        guard let source = source, source == .markAsSold else {
            return  LGLocalizedString.rateBuyersSubMessage
        }
        return LGLocalizedString.rateBuyersMessage
    }
    
    private func setSubtitle() -> String {
        guard let source = source, source == .markAsSold else {
            return ""
        }
        return LGLocalizedString.rateBuyersSubMessage
    }
}
