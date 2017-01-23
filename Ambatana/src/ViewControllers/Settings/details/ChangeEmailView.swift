//
//  ChangeEmailView.swift
//  LetGo
//
//  Created by Nestor on 19/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

class ChangeEmailView: UIView {
    
    let topMargin: CGFloat = 20
    let sideLabelMargin: CGFloat = 12
    let sideButtonMargin: CGFloat = 15
    let textFieldHeight: CGFloat = 44
    let buttonHeight: CGFloat = 50
    
    
    let emailTitleLabel: UILabel
    let emailLabel: UILabel
    let emailTextField: LGTextField
    let saveButton: UIButton
    
    // MARK: - Lifecycle
    
    init() {
        emailTitleLabel = UILabel()
        emailLabel = UILabel()
        emailTextField = LGTextField()
        saveButton = UIButton(type: .custom)
        
        super.init(frame: CGRect.zero)
        
        addSubviews([emailTitleLabel, emailLabel, emailTextField, saveButton])
        addConstraints()
        customizeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addBorders(to: emailTextField)
    }
    
    private func addConstraints() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [self, emailTitleLabel, emailLabel, emailTextField, saveButton])
        emailTitleLabel.layout(with: self).leading(by: sideLabelMargin).top(by: topMargin)
        emailLabel.layout(with: emailTitleLabel).leading(to: .trailing, by: 4).centerY()
        emailLabel.layout(with: self).trailing(relatedBy: .lessThanOrEqual, by: -sideLabelMargin)
        emailTextField.layout().height(textFieldHeight)
        emailTextField.layout(with: self).leading().trailing()
        emailTextField.layout(with: emailTitleLabel).top(to: .bottom, by: 5)
        saveButton.layout().height(buttonHeight)
        saveButton.layout(with: self).leading(by: sideButtonMargin).trailing(by: -sideButtonMargin)
        saveButton.layout(with: emailTextField).top(to: .bottom, by: sideButtonMargin)
    }
    
    private func addBorders(to view: UIView) {
        _ = view.addTopBorderWithWidth(1, color: UIColor.lineGray)
        _ = view.addBottomBorderWithWidth(1, color: UIColor.lineGray)
    }
    
    private func customizeUI() {
        backgroundColor = UIColor.grayBackground
        emailTitleLabel.textColor = UIColor.grayDark
        emailTitleLabel.font = UIFont.mediumBodyFont
        emailLabel.textColor = UIColor.black
        emailLabel.font = UIFont.mediumBodyFont
        emailTextField.backgroundColor = UIColor.white
        emailTextField.autocapitalizationType = .none
        emailTextField.spellCheckingType = .no
        emailTextField.autocorrectionType = .no
        emailTextField.returnKeyType = .send
        emailTextField.keyboardType = .emailAddress
        if #available(iOS 10, *) {
            emailTextField.textContentType = .emailAddress
        }
        saveButton.setStyle(.primary(fontSize: .big))
    }
}
