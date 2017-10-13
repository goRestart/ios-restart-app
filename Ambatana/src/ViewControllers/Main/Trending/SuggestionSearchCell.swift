//
//  SuggestionSearchCell.swift
//  LetGo
//
//  Created by Eli Kohen on 07/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class SuggestionSearchCell: UITableViewCell, ReusableCell {
    static let estimatedHeight: CGFloat = 44
    private static let titleSubtitleSpacing: CGFloat = 0
    
    private let searchIconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var titleSubtitleSpacing: NSLayoutConstraint?
    private let fillSearchButton = UIButton()
    
    var fillSearchButtonBlock: (() -> ())? {
        didSet {
            fillSearchButton.isHidden = fillSearchButtonBlock == nil
        }
    }
    
    
    // MARK: - Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        resetUI()
        setAccessibilityIds()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        
        searchIconImageView.contentMode = .center
        searchIconImageView.image = #imageLiteral(resourceName: "ic_search")
        
        fillSearchButton.contentVerticalAlignment = .top
        fillSearchButton.setImage(#imageLiteral(resourceName: "ic_search_fill"), for: .normal)
        
        titleLabel.textColor = UIColor.lgBlack
        titleLabel.font = UIFont.systemBoldFont(size: 21)
        
        titleLabel.numberOfLines = 1
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.font = UIFont.systemFont(size: 15)
        subtitleLabel.numberOfLines = 1
        
        fillSearchButton.addTarget(self, action: #selector(fillSearchButtonPressed), for: .touchUpInside)
        
        let subviews = [searchIconImageView, titleLabel, subtitleLabel, fillSearchButton]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        contentView.addSubviews(subviews)

        searchIconImageView.layout()
            .width(24)
        searchIconImageView.layout(with: contentView)
            .leading(by: Metrics.margin)
            .top(by: Metrics.shortMargin)
            .bottom(by: -Metrics.shortMargin)
        
        titleLabel.layout(with: contentView)
            .top(by: Metrics.margin)
        titleLabel.layout(with: searchIconImageView)
            .toLeft(by: 25)
        
        subtitleLabel.layout(with: contentView)
            .bottom(by: -Metrics.margin)
        subtitleLabel.layout(with: titleLabel)
            .below(by: 5) { [weak self] constraint in
                self?.titleSubtitleSpacing = constraint
            }
        subtitleLabel.layout(with: searchIconImageView)
            .toLeft(by: 25)
        
        fillSearchButton.layout()
            .width(28)
        let titleFontAdjustment = titleLabel.font.ascender - titleLabel.font.capHeight
        fillSearchButton.layout(with: contentView)
            .trailing(by: -Metrics.margin)
            .top(by: Metrics.shortMargin + titleFontAdjustment)
            .bottom()
        fillSearchButton.layout(with: titleLabel)
            .toLeft(by: Metrics.margin)
        fillSearchButton.layout(with: subtitleLabel)
            .toLeft(by: Metrics.margin)
    }
    
    private func setAccessibilityIds() {
        accessibilityId = .suggestionSearchCell
        titleLabel.accessibilityId = .suggestionSearchCellTitle
        subtitleLabel.accessibilityId = .suggestionSearchCellSubtitle
    }
    
    private func resetUI() {
        searchIconImageView.image = #imageLiteral(resourceName: "ic_search")
        titleLabel.text = nil
        subtitleLabel.text = nil
        fillSearchButton.isHidden = true
    }
    
    dynamic private func fillSearchButtonPressed(sender: AnyObject) {
        fillSearchButtonBlock?()
    }
    
    
    // MARK: - Setup
    
    func set(title: String,
             titleSkipHighlight: String?,
             subtitle: String?,
             icon: UIImage?) {
        if let titleLabelFont = titleLabel.font,
           let titleSkipHighlight = titleSkipHighlight {
            let titleWithHighlight = NSMutableAttributedString(string: title,
                                                               attributes: [NSFontAttributeName: titleLabelFont])
            let range = NSString(string: title).range(of: titleSkipHighlight,
                                                      options: [.caseInsensitive, .diacriticInsensitive])
            
            titleWithHighlight.addAttribute(
                NSForegroundColorAttributeName,
                value: UIColor.gray,
                range: range)
            titleLabel.attributedText = titleWithHighlight
        } else {
            titleLabel.text = title
        }
        subtitleLabel.text = subtitle
        
        let spacing: CGFloat = subtitle == nil ? 0 : SuggestionSearchCell.titleSubtitleSpacing
        titleSubtitleSpacing?.constant = spacing
        
        if let icon = icon {
            searchIconImageView.image = icon
        }
    }
}
