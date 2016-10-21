//
//  FilterTagCell.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol FilterTagCellDelegate : class {
    func onFilterTagClosed(filterTagCell: FilterTagCell)
}

class FilterTagCell: UICollectionViewCell {
    
    private static let cellHeigh : CGFloat = 32.0
    private static let fixedWidthSpace : CGFloat = 42.0 //10.0 left margin & 32.0 close button
    private static let iconWidth : CGFloat = 28.0
    private static let USDollarCode = "USD"

    @IBOutlet weak var tagIcon: UIImageView!
    @IBOutlet weak var tagIconWidth: NSLayoutConstraint!
    @IBOutlet weak var tagLabel: UILabel!
    
    weak var delegate : FilterTagCellDelegate?
    var filterTag : FilterTag?


    // MARK: - Static methods

    static func cellSizeForTag(tag : FilterTag) -> CGSize {
        switch tag {
        case .Location(let place):
            return FilterTagCell.sizeForText(place.fullText(showAddress: false))
        case .OrderBy(let sortOption):
            return FilterTagCell.sizeForText(sortOption.name)
        case .Within(let timeOption):
            return FilterTagCell.sizeForText(timeOption.name)
        case .Category:
            return CGSize(width: iconWidth+fixedWidthSpace, height: FilterTagCell.cellHeigh)
        case .PriceRange(let minPrice, let maxPrice, let currency):
            let priceRangeString  = FilterTagCell.stringForPriceRange(minPrice, max: maxPrice, withCurrency: currency)
            return FilterTagCell.sizeForText(priceRangeString)
        case .FreeStuff:
            return CGSize(width: iconWidth+fixedWidthSpace, height: FilterTagCell.cellHeigh)
        }
    }
    
    private static func sizeForText(text: String) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.max, height: FilterTagCell.cellHeigh)
        let boundingBox = text.boundingRectWithSize(constraintRect,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: UIFont.smallBodyFont], context: nil)
        return CGSize(width: boundingBox.width+fixedWidthSpace+5, height: FilterTagCell.cellHeigh)
    }

    private static func stringForPriceRange(min: Int?, max: Int?, withCurrency currency: Currency?) -> String {
        var minText = ""
        var maxText = ""
        if let min = min {
            minText = Core.currencyHelper.formattedAmountWithCurrencyCode(currency?.code ?? "", amount: min)
        }
        if let max = max {
            maxText = Core.currencyHelper.formattedAmountWithCurrencyCode(currency?.code ?? "", amount: max)
        }

        if !minText.isEmpty && !maxText.isEmpty {
            return minText + " " + "-" + " " + maxText
        } else if !minText.isEmpty {
            return LGLocalizedString.filtersPriceFrom + " " + minText
        } else if !maxText.isEmpty {
            return LGLocalizedString.filtersPriceTo + " " + maxText
        } else {
            // should never ever happen
            return "🤑"
        }
    }


    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
        self.setAccessibilityIds()
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
        case .Location(let place):
            self.tagLabel.text = place.fullText(showAddress: false)
        case .OrderBy(let sortOption):
            self.tagLabel.text = sortOption.name
        case .Within(let timeOption):
            self.tagLabel.text = timeOption.name
        case .Category(let category):
            self.tagIconWidth.constant = FilterTagCell.iconWidth
            self.tagIcon.image = category.image
        case .PriceRange(let minPrice, let maxPrice, let currency):
            self.tagLabel.text = FilterTagCell.stringForPriceRange(minPrice, max: maxPrice, withCurrency: currency)
        case .FreeStuff:
            self.tagIconWidth.constant = FilterTagCell.iconWidth
            self.tagIcon.image = UIImage(named: "categories_free")
        }
    }


    // MARK: - Private methods
    
    private func setupUI() {
        self.contentView.layer.borderColor = UIColor.lineGray.CGColor
        self.contentView.layer.borderWidth = LGUIKitConstants.onePixelSize
        self.contentView.layer.cornerRadius = 4.0
        self.contentView.layer.backgroundColor = UIColor.whiteColor().CGColor
    }
    
    private func resetUI() {
        self.tagLabel.text = nil
        self.tagIcon.image = nil
        self.tagIconWidth.constant = 0
    }

    private func setAccessibilityIds() {
        self.accessibilityId = .FilterTagCell
        tagIcon.accessibilityId = .FilterTagCellTagIcon
        tagLabel.accessibilityId = .FilterTagCellTagLabel
    }
}
