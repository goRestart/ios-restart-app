
import LGComponents

enum ServicesPromoCellConfiguration {
    case first(showsPostButton: Bool)
    case second(showsPostButton: Bool)
    case third(showsPostButton: Bool)
    case fourth(showsPostButton: Bool)
    case fifth(showsPostButton: Bool)
    
    private var configuration: PromoCellData {
        switch self {
        case .first(let showsPostButton):
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.ServicesPromos.Backgrounds.servicesBackground1),
                                 arrangement: .titleOnTop(showsPostButton: showsPostButton),
                                 attributedTitle: attributedTitle(),
                                 image: R.Asset.Verticals.ServicesPromos.Icons.servicesPromo1.image,
                                 type: .services)
        case .second(let showsPostButton):
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.ServicesPromos.Backgrounds.servicesBackground2),
                                 arrangement: .titleOnTop(showsPostButton: showsPostButton),
                                 attributedTitle: attributedTitle(),
                                 image: R.Asset.Verticals.ServicesPromos.Icons.servicesPromo2.image,
                                 type: .services)
        case .third(let showsPostButton):
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.ServicesPromos.Backgrounds.servicesBackground3),
                                 arrangement: .titleOnTop(showsPostButton: showsPostButton),
                                 attributedTitle: attributedTitle(),
                                 image: R.Asset.Verticals.ServicesPromos.Icons.servicesPromo3.image,
                                 type: .services)
        case .fourth(let showsPostButton):
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.ServicesPromos.Backgrounds.servicesBackground4),
                                 arrangement: .titleOnTop(showsPostButton: showsPostButton),
                                 attributedTitle: attributedTitle(),
                                 image: R.Asset.Verticals.ServicesPromos.Icons.servicesPromo4.image,
                                 type: .services)
        case .fifth(let showsPostButton):
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.ServicesPromos.Backgrounds.servicesBackground5),
                                 arrangement: .titleOnTop(showsPostButton: showsPostButton),
                                 attributedTitle: attributedTitle(),
                                 image: R.Asset.Verticals.ServicesPromos.Icons.servicesPromo5.image,
                                 type: .services)
        }
    }
    
    private func makeAppearance(withBackground background: R.ImageAsset) -> CellAppearance {
        return .backgroundImage(image: background.image,
                                titleColor: .white,
                                buttonStyle: .secondary(fontSize: .verySmallBold, withBorder: false),
                                buttonTitle: buttonTitle)
    }
    
    
    private func attributedTitle(withPrimaryFontSize primaryFontSize: CGFloat = 22.0,
                                 secondaryFontSize: CGFloat = 16.0) -> NSAttributedString? {
        
        switch self {
        case .first, .third, .fifth:
            let boldText = R.Strings.servicesPromoCellTitleDefaultBold
            let regularText = R.Strings.servicesPromoCellTitleDefaultRegular
            let text = "\(boldText)\n\(regularText)"
            return text.bifontAttributedText(highlightedText: boldText,
                                             mainFont: UIFont.systemFont(ofSize: secondaryFontSize),
                                             mainColour: .white,
                                             otherFont: UIFont.systemFont(ofSize: primaryFontSize,
                                                                          weight: UIFont.Weight.bold),
                                             otherColour: .white)
        case .second:
            let text = R.Strings.servicesPromoCellTitleB
            return NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                                 NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: primaryFontSize)])
        case .fourth:
            let text = R.Strings.servicesPromoCellTitleC
            return NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                                 NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: secondaryFontSize)])
        }
    }
    
    private var buttonTitle: String {
        switch self {
        case .first, .third, .fifth:
            return R.Strings.servicesPromoCallToAction
        case .second, .fourth:
            return R.Strings.realEstatePromoPostButtonTitle
        }
    }
    
    private static func allCases(showsPostButton show: Bool) -> [ServicesPromoCellConfiguration] {
        return [.first(showsPostButton: show),
                .second(showsPostButton: show),
                .third(showsPostButton: show),
                .fourth(showsPostButton: show),
                .fifth(showsPostButton: show)]
    }
    
    static func createRandomCellData(showsPostButton show: Bool) -> PromoCellData {
        let randomConfiguration = allCases(showsPostButton: show).random() ??
            .first(showsPostButton: show)
        return randomConfiguration.configuration
    }
}
