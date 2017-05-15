//
//  FilterDescriptionHeaderView.swift
//  LetGo
//
//  Created by Nestor on 15/05/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

class FilterDescriptionHeaderView: UIView {
    
    private let containerView = UIView()
    private let backgroundView = UIView()
    private let label = UILabel()
    
    private let topConstraint = NSLayoutConstraint()
    private let leftConstraint = NSLayoutConstraint()
    private let rightConstraint = NSLayoutConstraint()
    private let bottomConstraint = NSLayoutConstraint()
    
    var text: String? {
        set {
            if let text = newValue, !text.isEmpty {
                addLayoutMargins()
            } else {
                removeLayoutMargins()
            }
            label.text = newValue
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    /*override var intrinsicContentSize: CGSize {
        print("-------------------\(label.intrinsicContentSize)")
        return label.intrinsicContentSize
    }*/
    
    private func setupUI() {
        backgroundColor = UIColor.grayBackground.withAlphaComponent(0.95)
        backgroundView.backgroundColor = UIColor.grayLighter
        backgroundView.cornerRadius = 10
        
        label.font = UIFont.mediumBodyFont
        label.textColor = UIColor.darkGrayText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
    }
    
    private func setupLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [containerView, backgroundView, label])

        addSubview(containerView)
        containerView.addSubview(backgroundView)
        backgroundView.addSubview(label)

        removeLayoutMargins()
        
        containerView.layout(with: self)
            .top(to: .topMargin)
            .left(to: .leftMargin)
            .right(to: .rightMargin)
            .bottom(to: .bottomMargin)
        
        backgroundView.layout(with: containerView)
            .fill()
        
        label.layout(with: backgroundView)
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
        backgroundView.layoutMargins = UIEdgeInsets(top: Metrics.margin,
                                                    left: Metrics.margin,
                                                    bottom: Metrics.margin,
                                                    right: Metrics.margin)
    }
    
    private func removeLayoutMargins() {
        layoutMargins = UIEdgeInsets.zero
        backgroundView.layoutMargins = UIEdgeInsets.zero
    }
    
    // MARK: - Public methods
    
    func shrink() {
        
    }
}
