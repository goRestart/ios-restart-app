import UIKit
import LGCoreKit
import LGComponents

protocol FilterTagCellDelegate : class {
    func onFilterTagClosed(_ filterTagCell: FilterTagCell)
}

class FilterTagCell: UICollectionViewCell {
    
    private static let cellHeight: CGFloat = 32.0
    private static let fixedWidthSpace: CGFloat = 52.0 //15.0 left margin & 32.0 close button + 5 right margin
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
            return FilterTagCell.sizeForText(distance.intToDistanceFormat())
        case .carSellerType(_, let name):
            return FilterTagCell.sizeForText(name)
        case .make(_, let name):
            return FilterTagCell.sizeForText(name)
        case .model(_, let name):
            return FilterTagCell.sizeForText(name)
        case .yearsRange(let startYear, let endYear):
            return FilterTagCell.sizeForText(FilterTagCell.stringForYearsRange(startYear, endYear: endYear))
        case .realEstatePropertyType(let propertyType):
            return FilterTagCell.sizeForText(propertyType.shortLocalizedString)
        case .realEstateOfferType(let offerType):
            return FilterTagCell.sizeForText(offerType.shortLocalizedString.localizedCapitalized)
        case .realEstateNumberOfBedrooms(let numberOfBedrooms):
            return FilterTagCell.sizeForText(numberOfBedrooms.shortLocalizedString)
        case .realEstateNumberOfBathrooms(let numberOfBathrooms):
            return FilterTagCell.sizeForText(numberOfBathrooms.shortLocalizedString)
        case .realEstateNumberOfRooms(let numberOfRooms):
            return FilterTagCell.sizeForText(numberOfRooms.localizedString)
        case .sizeSquareMetersRange(let minSize, let maxSize):
            let sizeSquareMeters = FilterTagCell.stringForSizeRange(startSize: minSize, endSize: maxSize)
            return FilterTagCell.sizeForText(sizeSquareMeters)
        }
    }
    
    private static func sizeForText(_ text: String) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: FilterTagCell.cellHeight)
        let boundingBox = text.boundingRect(with: constraintRect,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedStringKey.font: UIFont.mediumBodyFont], context: nil)
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
            return R.Strings.filtersPriceFromFeedFilterCell + " " + minText
        } else if !maxText.isEmpty {
            return R.Strings.filtersPriceToFeedFilterCell + " " + maxText
        } else {
            // should never ever happen
            return "🤑"
        }
    }

    private static func stringForYearsRange(_ startYear: Int?, endYear: Int?) -> String {
        var startText = R.Strings.filtersCarYearBeforeYear(Constants.filterMinCarYear)
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
    
    private static func stringForSizeRange(startSize: Int?, endSize: Int?) -> String {
        var startText = ""
        var endText = ""
        
        if let startSize = startSize {
            startText = String(startSize)
        }
        if let endSize = endSize {
            endText = String(endSize)
        }
        
        if !startText.isEmpty && !endText.isEmpty {
            return startText.addingSquareMeterUnit + " " + "-" + " " + endText.addingSquareMeterUnit
        } else if !startText.isEmpty {
            return R.Strings.filtersRealEstateSizeFromFeedFilterCell + " " + startText.addingSquareMeterUnit
        } else if !endText.isEmpty {
            return R.Strings.filtersRealEstateSizeToFeedFilterCell + " " + endText.addingSquareMeterUnit
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
        contentView.layer.backgroundColor = UIColor.white.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.setRoundedCorners()
    }
    
    private func resetUI() {
        tagLabel.text = nil
        tagIcon.image = nil
        tagIconWidth.constant = 0
        tagLabel.textColor = .black
        contentView.backgroundColor = .white
    }
    
    private func applyCellStyle(tag: FilterTag) {
        switch tag {
        case .taxonomy(let taxonomy):
            setColoredCellStyle(taxonomy.color)
        case .location, .within, .orderBy, .category, .taxonomyChild, .secondaryTaxonomyChild, .priceRange,
             .freeStuff, .distance, .carSellerType, .make, .model, .yearsRange, .realEstateNumberOfBedrooms, .realEstateNumberOfBathrooms,
             .realEstatePropertyType, .realEstateOfferType, .sizeSquareMetersRange, .realEstateNumberOfRooms:
            setDefaultCellStyle()
        }
    }
    
    private func setAccessibilityIds() {
        tagIcon.set(accessibilityId: .filterTagCellTagIcon)
        tagLabel.set(accessibilityId: .filterTagCellTagLabel)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func onCloseBtn(_ sender: AnyObject) {
        delegate?.onFilterTagClosed(self)
    }


    // MARK: - Public methods
    
    func setupWithTag(_ tag : FilterTag) {
        filterTag = tag
        applyCellStyle(tag: tag)
        switch tag {
        case .location(let place):
            tagLabel.text = place.fullText(showAddress: false)
        case .orderBy(let sortOption):
            tagLabel.text = sortOption.name
        case .within(let timeOption):
            tagLabel.text = timeOption.name
        case .category(let category):
            tagIconWidth.constant = FilterTagCell.iconWidth
            tagIcon.image = category.imageTag
        case .taxonomyChild(let taxonomyChild):
            tagLabel.text = taxonomyChild.name
        case .taxonomy(let taxonomy):
            tagLabel.text = taxonomy.name
        case .secondaryTaxonomyChild(let secondaryTaxonomyChild):
            tagLabel.text = secondaryTaxonomyChild.name
        case .priceRange(let minPrice, let maxPrice, let currency):
            tagLabel.text = FilterTagCell.stringForPriceRange(minPrice, max: maxPrice, withCurrency: currency)
        case .freeStuff:
            tagIconWidth.constant = FilterTagCell.iconWidth
            tagIcon.image = UIImage(named: "categories_free_tag")
        case .distance(let distance):
            tagLabel.text = distance.intToDistanceFormat()
        case .carSellerType(_, let name):
            tagLabel.text = name
        case .make(_, let name):
            tagLabel.text = name
        case .model(_, let name):
            tagLabel.text = name
        case .yearsRange(let startYear, let endYear):
            tagLabel.text = FilterTagCell.stringForYearsRange(startYear, endYear: endYear)
        case .realEstatePropertyType(let propertyType):
            tagLabel.text = propertyType.shortLocalizedString.localizedCapitalized
        case .realEstateOfferType(let offerType):
            tagLabel.text = offerType.shortLocalizedString.localizedCapitalized
        case .realEstateNumberOfBedrooms(let numberOfBedrooms):
            tagLabel.text = numberOfBedrooms.shortLocalizedString
        case .realEstateNumberOfBathrooms(let numberOfBathrooms):
            tagLabel.text = numberOfBathrooms.shortLocalizedString
        case .sizeSquareMetersRange(let minSize, let maxSize):
            tagLabel.text = FilterTagCell.stringForSizeRange(startSize: minSize, endSize: maxSize)
        case .realEstateNumberOfRooms(let numberOfRooms):
            tagLabel.text = numberOfRooms.localizedString
        }
        set(accessibilityId: .filterTagCell(tag: tag))
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
