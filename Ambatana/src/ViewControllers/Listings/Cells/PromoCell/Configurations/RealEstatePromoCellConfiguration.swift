
import LGComponents

enum RealEstatePromoCellConfiguration: Int {
    case darkFirst, darkSecond, lightFirst, lightSecond, lightThird, lightFourth, lightFifth
    
    private var configuration: PromoCellData {
        switch self {
        case .darkFirst:
            return PromoCellData(appearance: .dark,
                                 arrangement: .imageOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion1,
                                 image: R.Asset.Verticals.RealEstatePromos.realEstatePromo1.image,
                                 type: .realEstate)
        case .darkSecond:
            return PromoCellData(appearance: .dark,
                                 arrangement: .imageOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion2,
                                 image: R.Asset.Verticals.RealEstatePromos.realEstatePromo2.image,
                                 type: .realEstate)
        case .lightFirst:
            return PromoCellData(appearance: .light,
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion3,
                                 image: R.Asset.Verticals.RealEstatePromos.realEstatePromo3.image,
                                 type: .realEstate)
        case .lightSecond:
            return PromoCellData(appearance: .light,
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion4,
                                 image: R.Asset.Verticals.RealEstatePromos.realEstatePromo4.image,
                                 type: .realEstate)
        case .lightThird:
            return PromoCellData(appearance: .light,
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion5,
                                 image: R.Asset.Verticals.RealEstatePromos.realEstatePromo5.image,
                                 type: .realEstate)
        case .lightFourth:
            return PromoCellData(appearance: .light,
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion6,
                                 image: R.Asset.Verticals.RealEstatePromos.realEstatePromo6.image,
                                 type: .realEstate)
        case .lightFifth:
            return PromoCellData(appearance: .light,
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion7,
                                 image: R.Asset.Verticals.RealEstatePromos.realEstatePromo7.image,
                                 type: .realEstate)
        }
    }
    
    static var all: [RealEstatePromoCellConfiguration] {
        return [.darkFirst, .darkSecond, .lightFirst, .lightSecond, .lightThird, .lightFourth, .lightFifth]
    }
    
    static var randomCellData: PromoCellData {
        let randomConfiguration = all.random() ?? .darkFirst
        return randomConfiguration.configuration
    }
}
