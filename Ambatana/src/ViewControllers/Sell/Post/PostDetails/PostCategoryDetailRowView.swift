//
//  AddCategoryDetailRowView.swift
//  LetGo
//
//  Created by Nestor on 10/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

enum PostCategoryDetailRowViewType {
    case defaultRow
    case textEntryRow
}

class PostCategoryDetailRowView: UIView, UITextFieldDelegate {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let textField = UITextField()
    private let icon = UIImageView()
    let button = UIButton()
    private let type: PostCategoryDetailRowViewType
    
    var isEnabled: Bool = false {
        didSet {
            button.isEnabled = isEnabled
            if isEnabled {
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
    
    let textInput = Variable<String?>(nil)
    
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
            textField.textAlignment = .left
            textField.clearButtonMode = .never
            textField.backgroundColor = UIColor.clear
            textField.textColor = UIColor.white
            textField.keyboardType = .numberPad
            textField.delegate = self
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
                .trailing(by: -Metrics.margin)
            textField.layout(with: titleLabel)
                .toLeft(by: Metrics.margin)
        }
    }
    
    // MARK: - TextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let text = (textFieldText as NSString).replacingCharacters(in: range, with: string)
            textInput.value = text
        }
        return true
    }

    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        button.accessibilityId = .postingCategoryDeatilRowButton
        textField.accessibilityId = .postingCategoryDeatilTextField
    }
}
