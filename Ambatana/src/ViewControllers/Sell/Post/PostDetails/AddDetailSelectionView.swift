//
//  AddDetailSelectionView.swift
//  LetGo
//
//  Created by Nestor on 10/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class AddDetailSelectionView: UIView {
    
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let icon = UIImageView()
    private let button = UIButton(type: .custom)
    let action: () -> ()
    
    var enabled: Bool = true {
        didSet {
            if enabled {
                titleLabel.textColor = UIColor.white
                valueLabel.text = ""
                icon.alpha = 1
            } else {
                titleLabel.textColor = UIColor.white.withAlphaComponent(0.3)
                icon.alpha = 0.7
            }
        }
    }
    
    var title: String {
        set {
            titleLabel.text = title
        }
        get {
            return titleLabel.text ?? ""
        }
    }
    
    var value: String {
        set {
            valueLabel.text = value
        }
        get {
            return valueLabel.text ?? ""
        }
    }
    
    // MARK: - Lifecycle
    
    init(withTitle title: String, value: String, action: @escaping () -> ()) {
        self.title = title
        self.value = value
        self.action = action
        
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
        button.addTarget(self, action: #selector(didPressDetail), for: .touchUpInside)
        
        titleLabel.font = UIFont.systemSemiBoldFont(size: 17)
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.white
        
        valueLabel.font = UIFont.systemSemiBoldFont(size: 17)
        valueLabel.textAlignment = .right
        valueLabel.textColor = UIColor.white.withAlphaComponent(0.3)
        
        icon.image = UIImage(named: "ic_arrow_down")
        icon.contentMode = .scaleAspectFit
    }
    
    private func setupLayout() {
        let subviews = [button, titleLabel, valueLabel, icon]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        button.layout(with: self).top().left().right().bottom()
        titleLabel.layout(with: self).top().bottom().leading()
        valueLabel.layout(with: self).top().bottom()
        valueLabel.layout(with: icon).trailing(to: .leading)
        icon.layout().height(13).proportionalWidth()
        icon.layout(with: self).top().bottom().trailing()
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        
    }
    
    // MARK: - Actions
    
    dynamic func didPressDetail() {
        if enabled {
            action()
        }
    }
}
