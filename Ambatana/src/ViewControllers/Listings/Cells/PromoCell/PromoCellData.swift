import LGComponents

enum PromoCellConfiguration: Int {
    case darkFirst, darkSecond, lightFirst, lightSecond, lightThird, lightFourth, lightFifth
    
    private var configuration: PromoCellData {
        switch self {
        case .darkFirst:
            return PromoCellData(appereance: .dark, arrangement: .imageOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion1,
                                 image: R.Asset.RealEstate.Promo.realEstatePromo1.image)
        case .darkSecond:
            return PromoCellData(appereance: .dark, arrangement: .imageOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion2,
                                 image: R.Asset.RealEstate.Promo.realEstatePromo2.image)
        case .lightFirst:
            return PromoCellData(appereance: .light, arrangement: .titleOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion3,
                                 image: R.Asset.RealEstate.Promo.realEstatePromo3.image)
        case .lightSecond:
            return PromoCellData(appereance: .light, arrangement: .titleOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion4,
                                 image: R.Asset.RealEstate.Promo.realEstatePromo4.image)
        case .lightThird:
            return PromoCellData(appereance: .light, arrangement: .titleOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion5,
                                 image: R.Asset.RealEstate.Promo.realEstatePromo5.image)
        case .lightFourth:
            return PromoCellData(appereance: .light, arrangement: .titleOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion6,
                                 image: R.Asset.RealEstate.Promo.realEstatePromo6.image)
        case .lightFifth:
            return PromoCellData(appereance: .light, arrangement: .titleOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion7,
                                 image: R.Asset.RealEstate.Promo.realEstatePromo7.image)
        }
    }

    static var all: [PromoCellConfiguration] {
        return [.darkFirst, .darkSecond, .lightFirst, .lightSecond, .lightThird, .lightFourth, .lightFifth]
    }
    
    static var randomCellData: PromoCellData {
        let randomConfiguration = all.random() ?? .darkFirst
        return randomConfiguration.configuration
    }
    
}
