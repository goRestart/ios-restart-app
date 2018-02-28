//
//  PostCategoryDetailProgressView.swift
//  LetGo
//
//  Created by Nestor on 06/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

final class PostCategoryDetailProgressView: UIView {
    
    private let progressView = UIProgressView()
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    
    private var imageViewCenterConstraint = NSLayoutConstraint()
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressView.setRoundedCorners()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric,
                      height: titleLabel.intrinsicContentSize.height
                        + progressView.intrinsicContentSize.height
                        + Metrics.margin)
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.smallBodyFont
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        
        progressView.progressTintColor = UIColor.white
        progressView.trackTintColor = UIColor.whiteTextLowAlpha
        
        imageView.image = UIImage(named: "ic_checkmark")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.white
        imageView.contentMode = .scaleAspectFit
    }
    
    private func setupLayout() {
        let subviews = [titleLabel, progressView, imageView]
        addSubviews(subviews)
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        
        layoutMargins = UIEdgeInsets(top: 0, left: Metrics.margin*2, bottom: 0, right: Metrics.margin*2)
        
        progressView.layout()
            .width(Metrics.screenWidth/3)
            .height(8)
            .width(120)
        progressView.layout(with: self)
            .centerX()
        
        titleLabel.layout(with: progressView)
            .below(by: 10)
        titleLabel.layout(with: self)
            .left(to: .leftMargin, by: Metrics.margin, relatedBy: .greaterThanOrEqual)
            .right(to: .rightMargin, by: -Metrics.margin, relatedBy: .lessThanOrEqual)
            .bottom()
            .centerX() { [weak self] in self?.imageViewCenterConstraint = $0 }

        imageView.layout()
            .height(13)
            .width(10)
        imageView.layout(with: titleLabel)
            .right(to: .left, by: -Metrics.veryShortMargin)
            .centerY()
    }
    
    // MARK: - Public methods
    
    func setPercentage(_ percentage: Float) {
        progressView.setProgress(percentage, animated: true)
        
        if percentage == Float(1) {
            progressView.progressTintColor = UIColor.asparagus
            titleLabel.text = LGLocalizedString.postCategoryDetailsProgress100
            imageViewCenterConstraint.constant = (imageView.frame.width + Metrics.veryShortMargin)/2
            imageView.alpha = 1
        } else {
            if percentage > 0.5 {
                progressView.progressTintColor = UIColor.macaroniAndCheese
            } else {
                progressView.progressTintColor = UIColor.white
            }
            titleLabel.text = LGLocalizedString.postCategoryDetailsProgress(String(Int(percentage*100))+"%")
            imageViewCenterConstraint.constant = 0
            imageView.alpha = 0
        }
    }
}
