//
//  ChatInactiveConversationHeaderView.swift
//  LetGo
//
//  Created by Nestor on 28/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

class ChatInactiveConversationHeaderView: UIView {

    private static let headerHeight: CGFloat = 55
    
    private let label = UILabel()
    private let button = UIButton(type: .custom)
    
    var buttonAction: (() -> ())? = nil
    var inactiveConvesationsCount: Int = 0 {
        didSet {
            updateButtonTitle(with: inactiveConvesationsCount)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: ChatInactiveConversationHeaderView.headerHeight)
    }
    
    // MARK: Lifecyle
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        setupLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI
    
    private func setupUI() {
        label.font = UIFont.systemRegularFont(size: 12)
        label.textColor = UIColor.blackTextHighAlpha
        label.text = LGLocalizedString.chatInactiveConversationsExplanationLabel
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.setStyle(.terciary)
        button.titleLabel?.font = UIFont.systemMediumFont(size: 12)
        button.titleLabel?.numberOfLines = 2
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func roundButton() {
        button.setRoundedCorners()
    }
    
    private func setupLayout() {
        let subviews = [label, button]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        layoutMargins = UIEdgeInsetsMake(Metrics.margin, Metrics.margin, Metrics.margin, Metrics.margin)
        label.layout(with: self).leadingMargin().topMargin().bottomMargin()
        label.layout(with: button).trailing(to: .leading, by: -Metrics.bigMargin)
        button.layout(with: self)
            .trailingMargin()
            .topMargin(relatedBy: .greaterThanOrEqual)
            .bottomMargin(relatedBy: .lessThanOrEqual)
            .centerY()
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        addBottomViewBorderWith(width: LGUIKitConstants.onePixelSize,
                                color: UIColor.grayLighter)
        addTopViewBorderWith(width: LGUIKitConstants.onePixelSize,
                             color: UIColor.grayLighter)
    }
    
    // MARK: UI Actions
    
    @objc func buttonPressed() {
        buttonAction?()
    }
    
    // MARK: Helpers
    
    private func generateButtonTitle(with counter: Int) -> String {
        return LGLocalizedString.chatInactiveConversationsButton + " (\(String(counter)))"
    }
    
    private func updateButtonTitle(with counter: Int) {
        let title = generateButtonTitle(with: counter)
        button.setTitle(title, for: .normal)
    }
}
