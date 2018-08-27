
import LGComponents

enum RealEstatePromoCellConfiguration: Int {
    case darkFirst, darkSecond, lightFirst, lightSecond, lightThird, lightFourth, lightFifth
    case first, second, third, fourth, fifth, sixth
    
    var configuration: PromoCellData {
        switch self {
        case .darkFirst:
            return PromoCellData(appearance: .dark,
                                 arrangement: .imageOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion1,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromo1.image,
                                 type: .realEstate)
        case .darkSecond:
            return PromoCellData(appearance: .dark,
                                 arrangement: .imageOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion2,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromo2.image,
                                 type: .realEstate)
        case .lightFirst:
            return PromoCellData(appearance: .light,
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion3,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromo3.image,
                                 type: .realEstate)
        case .lightSecond:
            return PromoCellData(appearance: .light,
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion4,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromo4.image,
                                 type: .realEstate)
        case .lightThird:
            return PromoCellData(appearance: .light,
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion5,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromo5.image,
                                 type: .realEstate)
        case .lightFourth:
            return PromoCellData(appearance: .light,
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion6,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromo6.image,
                                 type: .realEstate)
        case .lightFifth:
            return PromoCellData(appearance: .light,
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion7,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromo7.image,
                                 type: .realEstate)
        case .first:
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.RealEstatePromos.Backgrounds.realEstateBackground1),
                                 arrangement: .imageOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion1,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromoCell1.image,
                                 type: .realEstate)
        case .second:
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.RealEstatePromos.Backgrounds.realEstateBackground2),
                                 arrangement: .imageOnTop,
                                 title: R.Strings.realEstatePromoTitleVersion2,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromoCell2.image,
                                 type: .realEstate)
        case .third:
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.RealEstatePromos.Backgrounds.realEstateBackground3),
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion3,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromoCell3.image,
                                 type: .realEstate)
        case .fourth:
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.RealEstatePromos.Backgrounds.realEstateBackground4),
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion4,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromoCell4.image,
                                 type: .realEstate)
        case .fifth:
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.RealEstatePromos.Backgrounds.realEstateBackground5),
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion5,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromoCell5.image,
                                 type: .realEstate)
        case .sixth:
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.RealEstatePromos.Backgrounds.realEstateBackground6),
                                 arrangement: .titleOnTop(showsPostButton: true),
                                 title: R.Strings.realEstatePromoTitleVersion6,
                                 image: R.Asset.Verticals.RealEstatePromos.Icons.realEstatePromoCell6.image,
                                 type: .realEstate)
        }
    }
    
    private func makeAppearance(withBackground background: R.ImageAsset) -> CellAppearance {
        return .backgroundImage(image: background.image,
                                titleColor: .white,
                                buttonStyle: .secondary(fontSize: .verySmall, withBorder: false))
    }
    
    static var all: [RealEstatePromoCellConfiguration] {
        return [.darkFirst, .darkSecond, .lightFirst, .lightSecond, .lightThird, .lightFourth, .lightFifth]
    }
    
    static var allNewDesign: [RealEstatePromoCellConfiguration] {
        return [.first, .second, .third, .fourth, .fifth, .sixth]
    }
    
    static func createRandomCellData(showNewDesign: Bool) -> PromoCellData {
        let allConfigurations = showNewDesign ? allNewDesign : all
        let defaultConfiguration: RealEstatePromoCellConfiguration  = showNewDesign ? .first : .darkFirst
        return (allConfigurations.random() ?? defaultConfiguration).configuration
    }
    
}
