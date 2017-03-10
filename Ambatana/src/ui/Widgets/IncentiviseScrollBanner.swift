//
//  IncentiviseScrollBanner.swift
//  LetGo
//
//  Created by Juan Iglesias on 09/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

final class IncentiviseScrollBanner: UIView {
    
    let textLabel: UILabel = UILabel()
    let containerView: UIView = UIView()
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        layoutIfNeeded()
        addGradient()
    }
}


// MARK: - Private methods
fileprivate extension IncentiviseScrollBanner {
    func setupUI() {
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        containerView.addSubview(textLabel)
        
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor.gray
        textLabel.textAlignment = .center
        textLabel.text = LGLocalizedString.tabBarIncentiviseScrollBanner
    }
    
    func setupLayout() {
        containerView.layout(with: self).top().left().right().bottom()
        textLabel.layout(with: containerView).left(by: Metrics.margin).right(by: -Metrics.margin).bottom(by: Metrics.scrollBannerBottomMargin)
    }
    
    func addGradient() {
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.grayBackground, alphas:[0, 1], locations: [0, 0.5])
        shadowLayer.frame = containerView.bounds
        containerView.layer.insertSublayer(shadowLayer, at: 0)
    }
}
