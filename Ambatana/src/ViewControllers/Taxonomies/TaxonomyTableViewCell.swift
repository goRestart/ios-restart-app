//
//  TaxonomyTableViewCell.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import LGComponents

class TaxonomyTableViewCell: UITableViewCell {

    private static let iconViewWidth: CGFloat = 36
    private static let iconViewHeight: CGFloat = 36
    
    private let label = UILabel()
    private let iconView = UIImageView()

    
    // MARK: - Lifecycle
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    private func resetUI() {
        accessoryType = .none
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        selectionStyle = .none
        
        iconView.contentMode = .scaleAspectFit
        label.font = UIFont.smallBodyFont
        label.textColor = UIColor.grayDark
        label.numberOfLines = 1
        label.textAlignment = .left
    }
    
    private func setupLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [iconView, label])
        
        contentView.addSubviews([iconView, label])
        
        iconView.layout().width(TaxonomyTableViewCell.iconViewWidth).height(TaxonomyTableViewCell.iconViewHeight)
        iconView.layout(with: contentView).left(by: Metrics.margin).centerY()
        
        label.layout(with: iconView).fillVertical().left(to: .right, by: Metrics.margin)
        label.layout(with: contentView).right(by: -Metrics.margin)
    }
    
    func updateWith(text: String, iconURL: URL?, selected: Bool) {
        label.text = text.uppercased()
        
        if let url = iconURL {
            iconView.lg_setImageWithURL(url)
        }
        
        if selected {
            accessoryType = .checkmark
            tintColor = UIColor.redText
        }
    }
    
    func highlight() {
        accessoryType = .checkmark
        label.textColor = UIColor.redText
        tintColor = UIColor.redText
    }
}
