//
//  UserRatingTagCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 25/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class UserRatingTagCell: UICollectionViewCell {
    fileprivate let titleLabel = UILabel()
    fileprivate let style: ButtonStyle
    
    override var isSelected: Bool { didSet { updateUIWithCurrentState() } }
    override var isHighlighted: Bool { didSet { updateUIWithCurrentState() } }
    
    
    // MARK: - Lifecycle
    
    convenience init() {
        let style = ButtonStyle.secondary(fontSize: .medium, withBorder: true)
        self.init(style: style)
    }
    
    
    init(style: ButtonStyle) {
        self.style = style
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
}


// MARK: - Public methods

extension UserRatingTagCell {
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = title }
    }
}


// MARK: - Private methods

fileprivate extension UserRatingTagCell {
    
    func setupUI() {
        if style.withBorder {
            contentView.layer.borderColor = UIColor.primaryColor.cgColor
            contentView.layer.borderWidth = LGUIKitConstants.onePixelSize
        }
        contentView.rounded = style.applyCornerRadius
        contentView.layer.backgroundColor = style.backgroundColor.cgColor
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = style.titleColor
        titleLabel.font = style.titleFont
        contentView.addSubview(titleLabel)

    }
    
    func setupLayout() {
        titleLabel.layout(with: contentView).fillHorizontal(by: style.sidePadding)
        titleLabel.layout(with: contentView).fillVertical()
    }
    
    func resetUI() {
        titleLabel.text = nil
    }
    
    func updateUIWithCurrentState() {
        let titleColor: UIColor
        let bgColor: UIColor
        if isSelected {
            titleColor = style.backgroundColor
            bgColor = style.titleColor
        } else if isHighlighted {
            titleColor = style.titleColor
            bgColor = style.backgroundColorHighlighted
        } else {
            titleColor = style.titleColor
            bgColor = style.backgroundColor
        }
        titleLabel.textColor = titleColor
        contentView.layer.backgroundColor = bgColor.cgColor
    }
}

