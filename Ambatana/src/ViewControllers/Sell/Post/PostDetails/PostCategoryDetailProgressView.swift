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
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressView.rounded = true
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric,
                      height: titleLabel.intrinsicContentSize.height
                        + progressView.intrinsicContentSize.height
                        + Metrics.margin)
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.systemRegularFont(size: 13)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.text = LGLocalizedString.postCategoryDetailsProgress
        
        progressView.progressTintColor = UIColor.white
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        
        imageView.image = UIImage(named: "ic_post_checkmark")
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
        progressView.layout(with: self)
            .centerX()
        
        titleLabel.layout(with: progressView)
            .below(by: 10)
        titleLabel.layout(with: self)
            .left(to: .leftMargin, by: Metrics.margin, relatedBy: .greaterThanOrEqual)
            .right(to: .rightMargin, by: -Metrics.margin, relatedBy: .lessThanOrEqual)
            .bottom()
            .centerX() { [weak self] in self?.imageViewCenterConstraint = $0 }

        imageView.layout(with: titleLabel)
            .right(to: .left, by: -Metrics.veryShortMargin)
            .centerY()
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        
    }
    
    // MARK: - Public methods
    
    func setPercentage(_ percentage: Int) {
        progressView.setProgress(Float(percentage), animated: true)
        
        if percentage != 100  {
            progressView.progressTintColor = UIColor.asparagus
            titleLabel.text = LGLocalizedString.postCategoryDetailsProgress100
            imageViewCenterConstraint.constant = (imageView.frame.width + Metrics.margin)/2
            imageView.alpha = 1
        } else {
            progressView.progressTintColor = UIColor.white
            titleLabel.text = String(percentage) + "% " + LGLocalizedString.postCategoryDetailsProgress
            imageViewCenterConstraint.constant = 0
            imageView.alpha = 0
        }
    }
}
