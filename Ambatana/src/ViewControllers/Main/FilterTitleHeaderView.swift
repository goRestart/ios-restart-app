//
//  FilterTitleHeaderView.swift
//  LetGo
//
//  Created by Nestor on 15/05/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

class FilterTitleHeaderView: UIView {
    
    private let label = UILabel()
    
    var text: String? {
        set {
            if let text = newValue, !text.isEmpty {
                addLayoutMargins()
            } else {
                removeLayoutMargins()
            }
            label.text = newValue
            layoutIfNeeded()
        }
        get {
            return label.text
        }
    }
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        setupLayout()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        backgroundColor = UIColor.grayBackground.withAlphaComponent(0.95)
        
        label.font = UIFont.smallBodyFont
        label.textColor = UIColor.blackText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
    }
    
    private func setupLayout() {
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        removeLayoutMargins()
        label.layout(with: self)
            .top(to: .topMargin)
            .left(to: .leftMargin)
            .right(to: .rightMargin)
            .bottom(to: .bottomMargin)
    }
    
    private func addLayoutMargins() {
        layoutMargins = UIEdgeInsets(top: Metrics.shortMargin,
                                     left: Metrics.shortMargin,
                                     bottom: Metrics.shortMargin,
                                     right: Metrics.shortMargin)
    }
    
    private func removeLayoutMargins() {
        layoutMargins = UIEdgeInsets.zero
    }
}
