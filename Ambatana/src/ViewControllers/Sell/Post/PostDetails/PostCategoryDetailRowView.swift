//
//  AddCategoryDetailRowView.swift
//  LetGo
//
//  Created by Nestor on 10/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class PostCategoryDetailRowView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let icon = UIImageView()
    let button = UIButton()
    
    var enabled: Bool = true {
        didSet {
            if enabled {
                titleLabel.textColor = UIColor.white
                valueLabel.text = ""
                icon.alpha = 1
            } else {
                titleLabel.textColor = UIColor.whiteTextLowAlpha
                icon.alpha = 0.7
            }
        }
    }
    
    var title: String {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text ?? ""
        }
    }
    
    var value: String?  {
        set {
            valueLabel.text = newValue
        }
        get {
            return valueLabel.text
        }
    }
    
    // MARK: - Lifecycle
    
    init(withTitle title: String) {
        super.init(frame: CGRect.zero)
        self.title = title
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        titleLabel.font = UIFont.pageTitleFont
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.white
        
        valueLabel.font = UIFont.pageTitleFont
        valueLabel.textAlignment = .right
        valueLabel.textColor = UIColor.whiteTextLowAlpha
        
        icon.image = UIImage(named: "ic_post_disclousure")
        icon.contentMode = .scaleAspectFit
    }
    
    private func setupLayout() {
        let subviews = [button, titleLabel, valueLabel, icon]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        layoutMargins = UIEdgeInsets(top: 0, left: Metrics.margin*2, bottom: 0, right: Metrics.margin*2)
        
        button.layout(with: self)
            .fill()
        titleLabel.layout(with: self)
            .top()
            .bottom()
            .leading(to: .leadingMargin)
        valueLabel.layout(with: self)
            .top()
            .bottom()
        valueLabel.layout(with: icon)
            .trailing(to: .leading)
        icon.layout()
            .width(15).widthProportionalToHeight()
        icon.layout(with: self)
            .top()
            .bottom()
            .trailing(to: .trailingMargin)
    }
    
    func isFilled() -> Bool {
        return value != nil ? true : false
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        
    }
}
