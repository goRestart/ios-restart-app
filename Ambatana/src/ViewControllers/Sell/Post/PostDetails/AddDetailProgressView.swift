//
//  ProgressView.swift
//  LetGo
//
//  Created by Nestor on 06/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

final class AddDetailProgressView: UIView {
    
    private let progressView = UIProgressView()
    private let titleLabel = UILabel()
    
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
    
    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemRegularFont(size: 13)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.text = LGLocalizedString.carPostAddDetailsProgress
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor.white
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
    }
    
    private func setupLayout() {
        let subviews = [titleLabel, progressView]
        addSubviews(subviews)
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        
        progressView.layout().width(120).height(8)
        progressView.layout(with: self).centerX()
        progressView.layout(with: titlelLabel).top(by: Metrics.margin)
        titleLabel.layout(with: self).leading(by: Metrics.margin).trailing(by: -Metrics.margin).bottom()
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        
    }
    
    // MARK: - Public methods
    
    func setPercentage(_ percentage: Int) {
        progressView.setProgress(Float(percentage), animated: true)
        
        if percentage == 100  {
            progressView.progressTintColor = UIColor.asparagus
            titleLabel.text = String(percentage) + "% " + LGLocalizedString.carPostAddDetailsProgress100
        } else {
            progressView.progressTintColor = UIColor.white
            titleLabel.text = String(percentage) + "% " + LGLocalizedString.carPostAddDetailsProgress
        }
    }
}
