//
//  UserRatingTagCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 25/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class UserRatingTagCell: UICollectionViewCell {
    static let reuseIdentifier = "UserRatingTagCell"
    fileprivate static let height: CGFloat = 30
    fileprivate static let style: ButtonStyle = .secondary(fontSize: .medium, withBorder: true)
    
    fileprivate let titleLabel: UILabel
    
    override var isSelected: Bool { didSet { updateUIWithCurrentState() } }
    override var isHighlighted: Bool { didSet { updateUIWithCurrentState() } }
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        self.titleLabel = UILabel()
        super.init(frame: frame)
        
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
        set {
            titleLabel.text = title
        }
    }
    
    static func size(with title: String) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: UserRatingTagCell.height)
        let boundingBox = title.boundingRect(with: constraintRect,
                                             options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                             attributes: [NSFontAttributeName: UserRatingTagCell.style.titleFont],
                                             context: nil)
        return CGSize(width: boundingBox.width + UserRatingTagCell.style.sidePadding * 2,
                      height: UserRatingTagCell.height)
    }
}


// MARK: - Private methods

fileprivate extension UserRatingTagCell {
    func setupUI() {
        if UserRatingTagCell.style.withBorder {
            contentView.layer.borderColor = UIColor.primaryColor.cgColor
            contentView.layer.borderWidth = 1
        }
        contentView.rounded = UserRatingTagCell.style.applyCornerRadius
        contentView.layer.backgroundColor = UserRatingTagCell.style.backgroundColor.cgColor
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UserRatingTagCell.style.titleColor
        titleLabel.font = UserRatingTagCell.style.titleFont
        contentView.addSubview(titleLabel)

    }
    
    func setupLayout() {
        titleLabel.layout(with: contentView).fillHorizontal(by: UserRatingTagCell.style.sidePadding)
        titleLabel.layout(with: contentView).fillVertical()
    }
    
    func resetUI() {
        titleLabel.text = nil
    }
    
    func updateUIWithCurrentState() {
        let titleColor: UIColor
        let bgColor: UIColor
        if isHighlighted {
            titleColor = UserRatingTagCell.style.titleColor
            bgColor = UserRatingTagCell.style.backgroundColorHighlighted
        } else if isSelected {
            titleColor = UserRatingTagCell.style.backgroundColor
            bgColor = UserRatingTagCell.style.titleColor
        } else {
            titleColor = UserRatingTagCell.style.titleColor
            bgColor = UserRatingTagCell.style.backgroundColor
        }
        titleLabel.textColor = titleColor
        contentView.layer.backgroundColor = bgColor.cgColor
    }
}
