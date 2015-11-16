//
//  FilterTagCell.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

protocol FilterTagCellDelegate : class {
    func onFilterTagClosed(filterTagCell: FilterTagCell)
}

class FilterTagCell: UICollectionViewCell {
    
    private static let fixedWidthSpace : CGFloat = 50.0 //10.0 left margin & 40.0 close button

    @IBOutlet weak var tagIcon: UIImageView!
    @IBOutlet weak var tagIconWidth: NSLayoutConstraint!
    @IBOutlet weak var tagLabel: UILabel!
    
    weak var delegate : FilterTagCellDelegate?
    var filterTag : FilterTag?
    
    // MARK: - Static methods
    static func cellSizeForTag(tag : FilterTag) -> CGSize {
        switch tag {
        case .OrderBy(let sortOption):
            let constraintRect = CGSize(width: CGFloat.max, height: 40.0)
            let boundingBox = sortOption.name.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: StyleHelper.filterTagFont], context: nil)
            return CGSize(width: boundingBox.width+fixedWidthSpace+5, height: 40.0)
        case .Category:
            return CGSize(width: 40.0+fixedWidthSpace, height: 40.0)
        }
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    // MARK: - IBActions
    
    @IBAction func onCloseBtn(sender: AnyObject) {
        delegate?.onFilterTagClosed(self)
    }
    
    // MARK: - Public methods
    
    func setupWithTag(tag : FilterTag) {
        filterTag = tag
        
        switch tag {
        case .OrderBy(let sortOption):
            self.tagLabel.text = sortOption.name
        case .Category(let category):
            self.tagIconWidth.constant = 40
            self.tagIcon.image = category.image
        }
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        self.contentView.layer.borderColor = StyleHelper.lineColor.CGColor
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.cornerRadius = 4.0
        self.contentView.layer.backgroundColor = UIColor.whiteColor().CGColor
    }
    
    private func resetUI() {
        self.tagLabel.text = nil
        self.tagIcon.image = nil
        self.tagIconWidth.constant = 0
    }
}
