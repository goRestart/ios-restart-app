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
    func onFilterTagClosed(_ filterTagCell: FilterTagCell)
}

class FilterTagCell: UICollectionViewCell {
    
    private static let cellHeight: CGFloat = 32.0
    private static let fixedWidthSpace: CGFloat = 42.0 //10.0 left margin & 32.0 close button
    private static let iconWidth: CGFloat = 28.0
    private static let USDollarCode = "USD"

    @IBOutlet weak var tagIcon: UIImageView!
    @IBOutlet weak var tagIconWidth: NSLayoutConstraint!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    weak var delegate: FilterTagCellDelegate?
    var filterTag: FilterTag?


    // MARK: - Static methods

    static func cellSizeForTag(_ tag : FilterTag) -> CGSize {
        switch tag {
        case .location(let place):
            return FilterTagCell.sizeForText(place.fullText(showAddress: false))
        case .orderBy(let sortOption):
            return FilterTagCell.sizeForText(sortOption.name)
        case .within(let timeOption):
            return FilterTagCell.sizeForText(timeOption.name)
        case .category:
            return CGSize(width: iconWidth+fixedWidthSpace, height: FilterTagCell.cellHeight)
        case .taxonomyChild(let taxonomyChild):
            return FilterTagCell.sizeForText(taxonomyChild.name)
        case .taxonomy(let taxonomy):
            return FilterTagCell.sizeForText(taxonomy.name)
        case .secondaryTaxonomyChild(let secondaryTaxonomyChild):
            return FilterTagCell.sizeForText(secondaryTaxonomyChild.name)
        case .priceRange(let minPrice, let maxPrice, let currency):
            let priceRangeString = FilterTagCell.stringForPriceRange(minPrice, max: maxPrice, withCurrency: currency)
            return FilterTagCell.sizeForText(priceRangeString)
        case .freeStuff:
            return CGSize(width: iconWidth+fixedWidthSpace, height: FilterTagCell.cellHeight)
        case .distance(let distance):
            return FilterTagCell.sizeForText(distance.intToDistanteFormat())
        case .make(_, let name):
            return FilterTagCell.sizeForText(name)
        case .model(_, let name):
            return FilterTagCell.sizeForText(name)
        case .yearsRange(let startYear, let endYear):
            return FilterTagCell.sizeForText(FilterTagCell.stringForYearsRange(startYear, endYear: endYear))
        }
    }
    
    private static func sizeForText(_ text: String) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: FilterTagCell.cellHeight)
        let boundingBox = text.boundingRect(with: constraintRect,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: UIFont.mediumBodyFont], context: nil)
        return CGSize(width: boundingBox.width+fixedWidthSpace+5, height: FilterTagCell.cellHeight)
    }

    private static func stringForPriceRange(_ min: Int?, max: Int?, withCurrency currency: Currency?) -> String {
        var minText = ""
        var maxText = ""
        if let min = min {
            minText = Core.currencyHelper.formattedAmountWithCurrencyCode(currency?.code ?? "", amount: Double(min))
        }
        if let max = max {
            maxText = Core.currencyHelper.formattedAmountWithCurrencyCode(currency?.code ?? "", amount: Double(max))
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

    private static func stringForYearsRange(_ startYear: Int?, endYear: Int?) -> String {
        var startText = String(format: LGLocalizedString.filtersCarYearBeforeYear, Constants.filterMinCarYear)
        var endText = String(Date().year)

        if let startYear = startYear {
            startText = String(startYear)
        }
        if let endYear = endYear {
            endText = String(endYear)
        }

        if !startText.isEmpty && !endText.isEmpty {
            return startText + " " + "-" + " " + endText
        } else if !startText.isEmpty {
            return startText
        } else if !endText.isEmpty {
            return endText
        } else {
            // should never ever happen
            return ""
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
    
    private func setupUI() {
        contentView.layer.borderColor = UIColor.lineGray.cgColor
        contentView.layer.borderWidth = LGUIKitConstants.onePixelSize
        contentView.rounded = true
        contentView.layer.backgroundColor = UIColor.white.cgColor
    }
    
    private func resetUI() {
        tagLabel.text = nil
        tagIcon.image = nil
        tagIconWidth.constant = 0
        tagLabel.textColor = .black
        contentView.backgroundColor = .white
    }
    
    private func setAccessibilityIds() {
        accessibilityId = .filterTagCell
        tagIcon.accessibilityId = .filterTagCellTagIcon
        tagLabel.accessibilityId = .filterTagCellTagLabel
    }
    
    
    // MARK: - IBActions
    
    @IBAction func onCloseBtn(_ sender: AnyObject) {
        delegate?.onFilterTagClosed(self)
    }


    // MARK: - Public methods
    
    func setupWithTag(_ tag : FilterTag) {
        filterTag = tag
        
        switch tag {
        case .location(let place):
            setDefaultCellStyle()
            tagLabel.text = place.fullText(showAddress: false)
        case .orderBy(let sortOption):
            setDefaultCellStyle()
            tagLabel.text = sortOption.name
        case .within(let timeOption):
            setDefaultCellStyle()
            tagLabel.text = timeOption.name
        case .category(let category):
            setDefaultCellStyle()
            tagIconWidth.constant = FilterTagCell.iconWidth
            tagIcon.image = category.imageTag
        case .taxonomyChild(let taxonomyChild):
            setDefaultCellStyle()
            tagLabel.text = taxonomyChild.name
        case .taxonomy(let taxonomy):
            setColoredCellStyle(taxonomy.color)
            tagLabel.text = taxonomy.name
        case .secondaryTaxonomyChild(let secondaryTaxonomyChild):
            setDefaultCellStyle()
            tagLabel.text = secondaryTaxonomyChild.name
        case .priceRange(let minPrice, let maxPrice, let currency):
            setDefaultCellStyle()
            tagLabel.text = FilterTagCell.stringForPriceRange(minPrice, max: maxPrice, withCurrency: currency)
        case .freeStuff:
            setDefaultCellStyle()
            tagIconWidth.constant = FilterTagCell.iconWidth
            tagIcon.image = UIImage(named: "categories_free_tag")
        case .distance(let distance):
            setDefaultCellStyle()
            tagLabel.text = distance.intToDistanteFormat()
        case .make(_, let name):
            setDefaultCellStyle()
            tagLabel.text = name
        case .model(_, let name):
            setDefaultCellStyle()
            tagLabel.text = name
        case .yearsRange(let startYear, let endYear):
            setDefaultCellStyle()
            tagLabel.text = FilterTagCell.stringForYearsRange(startYear, endYear: endYear)
        }
    }


    // MARK: - Private methods
    
    private func setDefaultCellStyle() {
        tagLabel.textColor = .black
        contentView.backgroundColor = .white
        closeButton.setImage(UIImage(named: "filters_clear_btn"), for: .normal)
        closeButton.setImage(UIImage(named: "filters_clear_btn"), for: .highlighted)
    }
    
    private func setColoredCellStyle(_ color: UIColor) {
        tagLabel.textColor = .white
        contentView.backgroundColor = color
        closeButton.setImage(UIImage(named: "filters_taxonomy_clear_btn"), for: .normal)
        closeButton.setImage(UIImage(named: "filters_taxonomy_clear_btn"), for: .highlighted)
    }
}
