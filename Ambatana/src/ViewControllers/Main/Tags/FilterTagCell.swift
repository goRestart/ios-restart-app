import UIKit
import LGCoreKit
import LGComponents

protocol FilterTagCellDelegate : class {
    func onFilterTagClosed(_ filterTagCell: FilterTagCell)
}

final class FilterTagCell: UICollectionViewCell, ReusableCell {
    private enum Layout {
        enum Width {
            static let closeButton: CGFloat = 32
            static let fixedSpacing = Layout.leading + Layout.trailing + Layout.Width.closeButton + Layout.extraPadding
        }

        enum Height {
            static let cell: CGFloat = 32
        }
        static let leading: CGFloat = Metrics.margin
        static let trailing: CGFloat = Metrics.veryShortMargin
        static let extraPadding: CGFloat = 2
    }
    private static let USDollarCode = "USD"

    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemRegularFont(size: 14)
        label.textColor = .lgBlack
        label.textAlignment = .right
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
        case .category(let category):
            return FilterTagCell.sizeForText(category.name)
        case .priceRange(let minPrice, let maxPrice, let currency):
            let priceRangeString = FilterTagCell.stringForPriceRange(minPrice, max: maxPrice, withCurrency: currency)
            return FilterTagCell.sizeForText(priceRangeString)
        case .freeStuff:
            return FilterTagCell.sizeForText(R.Strings.categoriesFree)
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
        case .serviceListingType(let listingType):
            return FilterTagCell.sizeForText(listingType.pluralDisplayName)
        case .unifiedServiceType(let type, let selectedSubtypes):
             return FilterTagCell.sizeForText("\(type.name) +\(selectedSubtypes.count)")
        case .carBodyType(let bodyType):
            return FilterTagCell.sizeForText(bodyType.title)
        case .carFuelType(let fuelType):
            return FilterTagCell.sizeForText(fuelType.title)
        case .carTransmissionType(let transmissionType):
            return FilterTagCell.sizeForText(transmissionType.title)
        case .carDriveTrainType(let driveTrainType):
            return FilterTagCell.sizeForText(driveTrainType.title)
        case .mileageRange(let start, let end):
            let numberFormatter = NumberFormatter.newMileageNumberFormatter()
            let rangeString = FilterTagCell.stringForRange(fromValue: start,
                                                           toValue: end,
                                                           unit: DistanceType.systemDistanceType().localizedUnitType(),
                                                           isUnboundedUpperLimit: true,
                                                           numberFormatter: numberFormatter)
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


        let boundingBox = String(text.prefix(20)).boundingRect(with: constraintRect,
                                                               options: .usesLineFragmentOrigin,
                                                               attributes: [.font: UIFont.systemRegularFont(size: 14)],
                                                               context: nil)
        let emptySpace = Layout.Width.fixedSpacing
        return CGSize(width: ceil(boundingBox.width + emptySpace), height: Layout.Height.cell)
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
        var startText = R.Strings.filtersCarYearBeforeYear("\(SharedConstants.filterMinCarYear)")
        var endText = String(Date().nextYear)

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
                                       unit: String?,
                                       isUnboundedUpperLimit: Bool = false,
                                       numberFormatter: NumberFormatter? = nil) -> String {
        
        let startText = createStringForValue(value: fromValue, numberFormatter: numberFormatter)
        let endText = createStringForValue(value: toValue, numberFormatter: numberFormatter)
        var unitText = ""
        let upperLimitPostfix = FormattedUnitRange.upperValuePostfixString(shouldAppendPostfixString: isUnboundedUpperLimit)
        
        if let unit = unit {
            unitText = " \(unit)"
        }
        
        if !startText.isEmpty && !endText.isEmpty {
            return startText + " " + "-" + " " + endText + unitText
        } else if !startText.isEmpty {
            return R.Strings.filtersPriceFrom + " " + startText + unitText
        } else if !endText.isEmpty {
            return R.Strings.filtersPriceTo + " " + endText + upperLimitPostfix + unitText
        } else {
            return ""
        }
    }
    
    private static func createStringForValue(value: Int?,
                                             numberFormatter: NumberFormatter?) -> String {
        guard let value = value else { return "" }
        
        if let numberFormatter = numberFormatter,
            let formattedValue = numberFormatter.string(from: NSNumber(value: value)) {
            return formattedValue
        }
        
        return String(value)
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
        
        tagLabel.textColor = .black
        contentView.backgroundColor = .white
        closeButton.setImage(R.Asset.IconsButtons.filtersClearBtn.image, for: .normal)
        closeButton.setImage(R.Asset.IconsButtons.filtersClearBtn.image, for: .highlighted)
    }
    
    private func setupConstraints() {
        contentView.addSubviewsForAutoLayout([tagLabel, closeButton])
        NSLayoutConstraint.activate([
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.leading),
            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            closeButton.leadingAnchor.constraint(equalTo: tagLabel.trailingAnchor, constant: Layout.extraPadding),
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.trailing),
            closeButton.widthAnchor.constraint(equalToConstant: Layout.Width.closeButton)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.setRoundedCorners()
    }
    
    private func resetUI() {
        tagLabel.text = nil
        tagLabel.textColor = .black
        contentView.backgroundColor = .white
    }
    
    private func setAccessibilityIds() {
        tagLabel.set(accessibilityId: .filterTagCellTagLabel)
    }
    
    
    // MARK: - IBActions
    
    @objc private func onCloseBtn(_ sender: AnyObject) {
        delegate?.onFilterTagClosed(self)
    }


    // MARK: - Public methods
    
    func setupWithTag(_ tag : FilterTag) {
        filterTag = tag
        switch tag {
        case .location(let place):
            tagLabel.text = place.fullText(showAddress: false)
        case .orderBy(let sortOption):
            tagLabel.text = sortOption.name
        case .within(let timeOption):
            tagLabel.text = timeOption.name
        case .category(let category):
            tagLabel.text = category.name
        case .priceRange(let minPrice, let maxPrice, let currency):
            tagLabel.text = FilterTagCell.stringForPriceRange(minPrice, max: maxPrice, withCurrency: currency)
        case .freeStuff:
            tagLabel.text = R.Strings.categoriesFree
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
        case .serviceListingType(let listingType):
            tagLabel.text = listingType.pluralDisplayName
        case .unifiedServiceType(let type, let selectedSubtypes):
            tagLabel.text = "\(type.name) +\(selectedSubtypes.count)"
        case .mileageRange(let start, let end):
            let numberFormatter = NumberFormatter.newMileageNumberFormatter()
            tagLabel.text = FilterTagCell.stringForRange(fromValue: start,
                                                         toValue: end,
                                                         unit: DistanceType.systemDistanceType().localizedUnitType(),
                                                         isUnboundedUpperLimit: true,
                                                         numberFormatter: numberFormatter)
        case .numberOfSeats(let start, let end):
            tagLabel.text = FilterTagCell.stringForRange(fromValue: start,
                                                         toValue: end,
                                                         unit: R.Strings.filterCarsSeatsTitle)
        }
        set(accessibilityId: .filterTagCell(tag: tag))
    }
}
