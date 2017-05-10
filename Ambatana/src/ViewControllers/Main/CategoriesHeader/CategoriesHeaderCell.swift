//
//  CategoryHeaderCell.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit


class CategoryHeaderCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CategoryHeaderCell"
    
    var categoryIcon: UIImageView = UIImageView()
    var categoryTitle: UILabel = UILabel()
    var categoryNewLabel: UILabel = UILabel()
    var categoryNewContainter: UIView = UIView()
    
    
    // MARK: - Static methods
    
    static func cellSize() -> CGSize {
        return CGSize(width: 80, height: 120)
    }

    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        categoryIcon.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        categoryIcon.contentMode = .scaleAspectFit
        contentView.addSubview(categoryIcon)
        contentView.addSubview(categoryTitle)
        contentView.addSubview(categoryNewContainter)
        categoryNewContainter.addSubview(categoryNewLabel)
        self.setupUI()
        self.resetUI()
        self.setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    override func layoutSubviews() {
        categoryNewContainter.rounded = true
        super.layoutSubviews()
    }
    
    
    // MARK: - Public Methods
    
    func addNewTagToCategory() {
        categoryNewContainter.isHidden = false
        categoryNewLabel.text = LGLocalizedString.commonNew
        layoutIfNeeded()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        
        backgroundColor = UIColor.clear
        categoryNewContainter.backgroundColor = UIColor.white
        categoryNewLabel.backgroundColor = UIColor.clear
        
        categoryTitle.translatesAutoresizingMaskIntoConstraints = false
        categoryNewLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryIcon.translatesAutoresizingMaskIntoConstraints = false
        categoryNewContainter.translatesAutoresizingMaskIntoConstraints = false
        
        let subviews = [categoryTitle, categoryNewLabel, categoryIcon, categoryNewContainter]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        
        categoryTitle.font = UIFont.boldSystemFont(ofSize: 9)
        categoryNewLabel.font = UIFont.boldSystemFont(ofSize: 9)
        
        categoryTitle.textColor = UIColor.grayDark
        categoryNewLabel.textColor = UIColor.lgBlack
        
        categoryIcon.layout().height(60).width(60)
        categoryIcon.layout(with: contentView).top(by: 20).centerX()
        categoryTitle.layout(with: contentView).bottom(by: -10).left().right()
        categoryTitle.layout().height(20)
        categoryTitle.textAlignment = .center
        categoryNewContainter.layout(with: contentView).top(by: 10).centerX()
        
        categoryNewLabel.layout(with: categoryNewContainter).top(by: 3).left(by: 10).right(by: -10).bottom(by: -3)
        categoryNewLabel.textAlignment = .center
        
        categoryNewContainter.applyDefaultShadow()
    }
    
    private func resetUI() {
        categoryTitle.text = ""
        categoryNewLabel.text = ""
        categoryIcon.image = nil
        categoryNewContainter.isHidden = true
    }
    
    private func setAccessibilityIds() {
        self.accessibilityId = .filterTagCell
        categoryIcon.accessibilityId = .categoryHeaderCellCategoryIcon
        categoryTitle.accessibilityId = .categoryHeaderCellCategoryTitle
    }
}
