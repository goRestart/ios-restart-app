//
//  TaxonomyHeaderView.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

class TaxonomyHeaderView: UIView {
    
    private let containerView = UIView()
    private let label = UILabel()
    private let iconView = UIImageView()
    
    
    // MARK: - Lifecycle
    
    init(title: String, iconURL: URL?) {
        super.init(frame: CGRect.zero)
        setupUI(title: title, iconURL: iconURL)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI(title: String, iconURL: URL?) {
        
        iconView.contentMode = .scaleAspectFit
        label.font = UIFont.smallBodyFont
        label.textColor = UIColor.grayDark
        label.numberOfLines = 1
        label.textAlignment = .left
        
        label.text = title.uppercased()
        if let url = iconURL {
            iconView.lg_setImageWithURL(url)
        }
    }
    
    private func setupLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [containerView, iconView, label])
        
        addSubview(containerView)
        containerView.addSubviews([iconView, label])
        
        containerView.layout(with: self).fill()
        
        iconView.layout().width(36).height(36)
        iconView.layout(with: containerView).left(by: Metrics.margin).centerY()
        
        label.layout(with: iconView).fillVertical().left(to: .right, by: Metrics.margin)
        label.layout(with: containerView).right(by: -Metrics.margin)
    }
}
