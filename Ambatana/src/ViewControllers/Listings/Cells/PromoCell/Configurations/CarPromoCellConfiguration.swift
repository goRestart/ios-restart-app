
import LGComponents

enum CarPromoCellConfiguration {
    case first(showsPostButton: Bool)
    case second(showsPostButton: Bool)
    case third(showsPostButton: Bool)
    case fourth(showsPostButton: Bool)
    case fifth(showsPostButton: Bool)
    
    private var configuration: PromoCellData {
        switch self {
        case .first(let showsPostButton):
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.CarPromos.Backgrounds.background1),
                                 arrangement: .titleOnTop(showsPostButton: showsPostButton),
                                 attributedTitle: attributedTitle,
                                 image: R.Asset.Verticals.CarPromos.Icons.promo1.image,
                                 type: .car)
        case .second(let showsPostButton):
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.CarPromos.Backgrounds.background2),
                                 arrangement: .titleOnTop(showsPostButton: showsPostButton),
                                 attributedTitle: attributedTitle,
                                 image: R.Asset.Verticals.CarPromos.Icons.promo2.image,
                                 type: .car)
        case .third(let showsPostButton):
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.CarPromos.Backgrounds.background3),
                                 arrangement: .titleOnTop(showsPostButton: showsPostButton),
                                 attributedTitle: attributedTitle,
                                 image: R.Asset.Verticals.CarPromos.Icons.promo3.image,
                                 type: .car)
        case .fourth(let showsPostButton):
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.CarPromos.Backgrounds.background4),
                                 arrangement: .titleOnTop(showsPostButton: showsPostButton),
                                 attributedTitle: attributedTitle,
                                 image: R.Asset.Verticals.CarPromos.Icons.promo4.image,
                                 type: .car)
        case .fifth(let showsPostButton):
            return PromoCellData(appearance: makeAppearance(withBackground: R.Asset.Verticals.CarPromos.Backgrounds.background5),
                                 arrangement: .titleOnTop(showsPostButton: showsPostButton),
                                 attributedTitle: attributedTitle,
                                 image: R.Asset.Verticals.CarPromos.Icons.promo5.image,
                                 type: .car)
        }
    }
    
    private func makeAppearance(withBackground background: R.ImageAsset) -> CellAppearance {
        return .backgroundImage(image: background.image,
                                titleColor: .white,
                                buttonStyle: .secondary(fontSize: .verySmallBold, withBorder: false))
    }
    
    private var attributedTitle: NSAttributedString? {
        let boldText = R.Strings.carPromoCellTitleBoldText
        let regularText = R.Strings.carPromoCellTitleRegularText
        
        let text = "\(boldText)\n\(regularText)"
        
        return text.bifontAttributedText(highlightedText: boldText,
                                         mainFont: UIFont.systemFont(ofSize: 16.0),
                                         mainColour: .white,
                                         otherFont: UIFont.systemFont(ofSize: 22.0,
                                                                      weight: UIFont.Weight.bold),
                                         otherColour: .white)
    }
    
    private static func allCases(showsPostButton show: Bool) -> [CarPromoCellConfiguration] {
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
