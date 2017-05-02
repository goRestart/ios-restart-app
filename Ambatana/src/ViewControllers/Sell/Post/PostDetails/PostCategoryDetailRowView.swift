//
//  AddCategoryDetailRowView.swift
//  LetGo
//
//  Created by Nestor on 10/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

enum PostCategoryDetailRowViewType {
    case defaultRow
    case textEntryRow
}

class PostCategoryDetailRowView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let textField = UITextField()
    private let icon = UIImageView()
    let button = UIButton()
    private let type: PostCategoryDetailRowViewType
    
    private var highlighted: Bool = false {
        didSet {
            if highlighted {
                titleLabel.textColor = UIColor.white
                icon.alpha = 1
            } else {
                titleLabel.textColor = UIColor.whiteTextLowAlpha
                icon.alpha = 0.7
            }
        }
    }
    
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            return titleLabel.text ?? ""
        }
    }
    
    var value: String? {
        set {
            valueLabel.text = newValue
            if let string = newValue, !string.isEmpty {
                highlighted = true
            }  else {
                highlighted = false
            }
        }
        get {
            return valueLabel.text
        }
    }
    
    var placeholder: String? {
        set {
            if let value = newValue {
                textField.attributedPlaceholder =
                    NSAttributedString(string: value,
                                       attributes: [NSForegroundColorAttributeName: UIColor.whiteTextHighAlpha])
            }
        }
        get {
            return textField.placeholder
        }
    }
    
    func hideKeyboard() {
        textField.resignFirstResponder()
    }
    
    // MARK: - Lifecycle
    
    init(withTitle title: String, type: PostCategoryDetailRowViewType = .defaultRow) {
        self.type = type
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
        titleLabel.font = UIFont.mediumButtonFont
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.white
        
        switch type {
        case .defaultRow:
            valueLabel.font = UIFont.bigBodyFont
            valueLabel.textAlignment = .right
            valueLabel.textColor = UIColor.whiteTextLowAlpha
            icon.image = UIImage(named: "ic_post_disclousure")
            icon.contentMode = .scaleAspectFit
        case .textEntryRow:
            textField.textAlignment = .right
            textField.clearButtonMode = .never
            textField.backgroundColor = UIColor.clear
            textField.textColor = UIColor.white
            textField.keyboardType = .numberPad
        }
    }
    
    private func setupLayout() {
        let subviews = [button, titleLabel, valueLabel, textField, icon]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        layoutMargins = UIEdgeInsets(top: 0, left: Metrics.margin*2, bottom: 0, right: Metrics.margin*2)
        
        switch type {
        case .defaultRow:
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
                .trailing(to: .leading, by: -Metrics.margin)
            icon.layout()
                .width(15).widthProportionalToHeight()
            icon.layout(with: self)
                .top()
                .bottom()
                .trailing(to: .trailingMargin)
        case .textEntryRow:
            titleLabel.layout()
                .width(35)
            titleLabel.layout(with: self)
                .top()
                .bottom()
                .leading(to: .leadingMargin)
            textField.layout(with: self)
                .top()
                .bottom()
                .trailing(to: .centerX)
            textField.layout(with: titleLabel)
                .toLeft(by: Metrics.margin)
        }
    }

    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        button.accessibilityId = .postingCategoryDeatilRowButton
        textField.accessibilityId = .postingCategoryDeatilTextField
    }
}
