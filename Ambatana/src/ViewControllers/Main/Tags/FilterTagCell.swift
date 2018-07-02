import UIKit
import LGCoreKit
import LGComponents

protocol FilterTagCellDelegate : class {
    func onFilterTagClosed(_ filterTagCell: FilterTagCell)
}

final class FilterTagCell: UICollectionViewCell, ReusableCell {
    private struct Layout {
        struct Width {
            static let icon: CGFloat = 28
            static let closeButton: CGFloat = 32
            static let fixedSpace: CGFloat = 52 //15.0 left margin & 32.0 close button + 5 right margin
        }
        struct Height {
            static let cell: CGFloat = 32
        }
        static let margin: CGFloat = 2
    }
    private static let USDollarCode = "USD"

    private let tagIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private var tagIconWidth: NSLayoutConstraint?

    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.mediumBodyFont
        return label
    }()
    private let closeButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(R.Asset.IconsButtons.filtersClearBtn.image, for: .normal)
        button.setImage(R.Asset.IconsButtons.filtersClearBtn.image, for: .highlighted)
        return button
    }()
    
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
            return CGSize(width: Layout.Width.icon + Layout.Width.fixedSpace, height: Layout.Height.cell)
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
            return CGSize(width: Layout.Width.icon + Layout.Width.fixedSpace, height: Layout.Height.cell)
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
        case .serviceType(let serviceType):
            return FilterTagCell.sizeForText(serviceType.name)
        case .serviceSubtype(let serviceSubtype):
            return FilterTagCell.sizeForText(serviceSubtype.name)
        case .carBodyType(let bodyType):
            return FilterTagCell.sizeForText(bodyType.title)
        case .carFuelType(let fuelType):
            return FilterTagCell.sizeForText(fuelType.title)
        case .carTransmissionType(let transmissionType):
            return FilterTagCell.sizeForText(transmissionType.title)
        case .carDriveTrainType(let driveTrainType):
            return FilterTagCell.sizeForText(driveTrainType.title)
        case .mileageRange(let start, let end):
            let rangeString = FilterTagCell.stringForRange(fromValue: start,
                                                      toValue: end,
                                                      unit: DistanceType.systemDistanceType().localizedUnitType())
            return FilterTagCell.sizeForText(rangeString)
        case .numberOfSeats(let start, let end):
            let rangeString = FilterTagCell.stringForRange(fromValue: start,
                                                           toValue: end,
                                                           unit: R.Strings.filterCarsSeatsTitle)
            return FilterTagCell.sizeForText(rangeString)
        }
    }
    
    private static func sizeForText(_ text: String) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: Layout.Height.cell)
        let boundingBox = text.boundingRect(with: constraintRect,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedStringKey.font: UIFont.mediumBodyFont], context: nil)
        return CGSize(width: boundingBox.width + Layout.Width.fixedSpace + 5, height: Layout.Height.cell)
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
        var startText = R.Strings.filtersCarYearBeforeYear(SharedConstants.filterMinCarYear)
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
    
    private static func stringForRange(fromValue: Int?,
                                       toValue: Int?,
                                       unit: String?) -> String {
        var startText = ""
        var endText = ""
        var unitText = ""
        
        if let fromValue = fromValue {
            startText = String(fromValue)
        }
        if let toValue = toValue {
            endText = String(toValue)
        }
        
        if let unit = unit {
            unitText = " \(unit)"
        }
        
        if !startText.isEmpty && !endText.isEmpty {
            return startText + " " + "-" + " " + endText + unitText
        } else if !startText.isEmpty {
            return R.Strings.filtersPriceFrom + " " + startText + unitText
        } else if !endText.isEmpty {
            return R.Strings.filtersPriceTo + " " + endText + unitText
        } else {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        resetUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    private func setupUI() {
        contentView.layer.borderColor = UIColor.lineGray.cgColor
        contentView.layer.borderWidth = LGUIKitConstants.onePixelSize
        contentView.layer.backgroundColor = UIColor.white.cgColor
        setupConstraints()
        closeButton.addTarget(self, action: #selector(onCloseBtn), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        let iconWidth = tagIcon.widthAnchor.constraint(equalToConstant: Layout.Width.icon)
        contentView.addSubviewsForAutoLayout([tagIcon, tagLabel, closeButton])
        NSLayoutConstraint.activate([
            tagIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            tagIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.margin),
            tagIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.margin),

            tagLabel.leadingAnchor.constraint(equalTo: tagIcon.trailingAnchor),
            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            closeButton.leadingAnchor.constraint(equalTo: tagLabel.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2*Layout.margin),
            closeButton.widthAnchor.constraint(equalToConstant: Layout.Width.closeButton)
        ])

        tagIconWidth = iconWidth
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.setRoundedCorners()
    }
    
    private func resetUI() {
        tagLabel.text = nil
        tagIcon.image = nil
        tagIconWidth?.constant = 0
        tagLabel.textColor = .black
        contentView.backgroundColor = .white
    }
    
    private func applyCellStyle(tag: FilterTag) {
        switch tag {
        case .taxonomy(let taxonomy):
            setColoredCellStyle(taxonomy.color)
        case .location, .within, .orderBy, .category, .taxonomyChild, .secondaryTaxonomyChild, .priceRange,
             .freeStuff, .distance, .carSellerType, .make, .model, .yearsRange, .realEstateNumberOfBedrooms, .realEstateNumberOfBathrooms,
             .realEstatePropertyType, .realEstateOfferType, .sizeSquareMetersRange, .realEstateNumberOfRooms,
             .serviceType, .serviceSubtype, .carDriveTrainType, .carBodyType, .carFuelType, .carTransmissionType,
             .mileageRange, .numberOfSeats:
            setDefaultCellStyle()
        }
    }
    
    private func setAccessibilityIds() {
        tagIcon.set(accessibilityId: .filterTagCellTagIcon)
        tagLabel.set(accessibilityId: .filterTagCellTagLabel)
    }
    
    
    // MARK: - IBActions
    
    @objc private func onCloseBtn(_ sender: AnyObject) {
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
            tagIconWidth?.constant = Layout.Width.icon
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
            tagIconWidth?.constant = Layout.Width.icon
            tagIcon.image = R.Asset.IconsButtons.FiltersTagCategories.categoriesFreeTag.image
        case .distance(let distance):
            tagLabel.text = distance.intToDistanceFormat()
        case .carSellerType(_, let name):
            tagLabel.text = name
        case .make(_, let name):
            tagLabel.text = name
        case .model(_, let name):
            tagLabel.text = name
        case .carDriveTrainType(let driveTrainType):
            tagLabel.text = driveTrainType.title
        case .carFuelType(let fuelType):
            tagLabel.text = fuelType.title
        case .carBodyType(let bodyType):
            tagLabel.text = bodyType.title
        case .carTransmissionType(let transmissionType):
            tagLabel.text = transmissionType.title
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
        case .serviceType(let serviceType):
            tagLabel.text = serviceType.name
        case .serviceSubtype(let subtype):
            tagLabel.text = subtype.name
        case .mileageRange(let start, let end):
            tagLabel.text = FilterTagCell.stringForRange(fromValue: start,
                                                         toValue: end,
                                                         unit: DistanceType.systemDistanceType().localizedUnitType())
        case .numberOfSeats(let start, let end):
            tagLabel.text = FilterTagCell.stringForRange(fromValue: start,
                                                         toValue: end,
                                                         unit: R.Strings.filterCarsSeatsTitle)
        }
        set(accessibilityId: .filterTagCell(tag: tag))
    }


    // MARK: - Private methods
    
    private func setDefaultCellStyle() {
        tagLabel.textColor = .black
        contentView.backgroundColor = .white
        closeButton.setImage(R.Asset.IconsButtons.filtersClearBtn.image, for: .normal)
        closeButton.setImage(R.Asset.IconsButtons.filtersClearBtn.image, for: .highlighted)
    }
    
    private func setColoredCellStyle(_ color: UIColor) {
        tagLabel.textColor = .white
        contentView.backgroundColor = color
        closeButton.setImage(R.Asset.IconsButtons.filtersTaxonomyClearBtn.image, for: .normal)
        closeButton.setImage(R.Asset.IconsButtons.filtersTaxonomyClearBtn.image, for: .highlighted)
    }
}
