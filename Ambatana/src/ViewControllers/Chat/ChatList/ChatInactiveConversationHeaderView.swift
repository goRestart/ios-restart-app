//
//  ChatInactiveConversationHeaderView.swift
//  LetGo
//
//  Created by Nestor on 28/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

class ChatInactiveConversationHeaderView: UIView {

    private let label = UILabel()
    private let button = UIButton(type: .custom)
    
    let buttonAction: (() -> ())? = nil
    var inactiveConvesationsCount: Int = 0 {
        didSet {
            updateButtonTitle(with: inactiveConvesationsCount)
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        label.font = UIFont.systemRegularFont(size: 12)
        label.textColor = UIColor.blackTextHighAlpha
        label.text = LGLocalizedString.chatInactiveConversationsExplanationLabel
        label.numberOfLines = 2
        button.setStyle(.secondary(fontSize: .medium, withBorder: false))
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    private func setupLayout() {
        let subviews = [label, button]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        layoutMargins = UIEdgeInsetsMake(Metrics.margin, Metrics.margin, Metrics.margin, Metrics.margin)
        label.layout(with: self).leadingMargin().topMargin().bottomMargin()
        label.layout(with: button).trailing(to: .leading, by: Metrics.veryBigMargin)
        button.layout(with: self).trailingMargin().topMargin().bottomMargin()
    }
    
    @objc func buttonPressed() {
        buttonAction?()
    }
    
    private func generateButtonTitle(with counter: Int) -> String {
        return LGLocalizedString.chatInactiveConversationsButton + " (\(String(counter))"
    }
    
    private func updateButtonTitle(with counter: Int) {
        let title = generateButtonTitle(with: counter)
        button.setTitle(title, for: .normal)
    }
}
