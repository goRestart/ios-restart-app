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
        containerView.backgroundColor = UIColor.grayLight
        textLabel.text = LGLocalizedString.tabBarIncentiviseScrollBanner
    }
    
    func setupLayout() {
        textLabel.layout(with: containerView).top().left(by: Metrics.margin).right(by: -Metrics.margin).bottom()
    }
}
