//
//  PromoCellData.swift
//  LetGo
//
//  Created by Tomas Cobo on 06/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

enum PromoCellConfiguration: Int {
    case darkFirst, darkSecond, lightFirst, lightSecond, lightThird, lightFourth, lightFifth
    
    private var configuration: PromoCellData {
        switch self {
        case .darkFirst:
            return PromoCellData(appereance: .dark, arrangement: .imageOnTop,
                                 title: LGLocalizedString.realEstatePromoTitleVersion1, image: #imageLiteral(resourceName: "real-estate-promo-1"))
        case .darkSecond:
            return PromoCellData(appereance: .dark, arrangement: .imageOnTop,
                                 title: LGLocalizedString.realEstatePromoTitleVersion2, image: #imageLiteral(resourceName: "real-estate-promo-2"))
        case .lightFirst:
            return PromoCellData(appereance: .light, arrangement: .titleOnTop,
                                 title: LGLocalizedString.realEstatePromoTitleVersion3, image: #imageLiteral(resourceName: "real-estate-promo-3"))
        case .lightSecond:
            return PromoCellData(appereance: .light, arrangement: .titleOnTop,
                                 title: LGLocalizedString.realEstatePromoTitleVersion4, image: #imageLiteral(resourceName: "real-estate-promo-4"))
        case .lightThird:
            return PromoCellData(appereance: .light, arrangement: .titleOnTop,
                                 title: LGLocalizedString.realEstatePromoTitleVersion5, image: #imageLiteral(resourceName: "real-estate-promo-5"))
        case .lightFourth:
            return PromoCellData(appereance: .light, arrangement: .titleOnTop,
                                 title: LGLocalizedString.realEstatePromoTitleVersion6, image: #imageLiteral(resourceName: "real-estate-promo-6"))
        case .lightFifth:
            return PromoCellData(appereance: .light, arrangement: .titleOnTop,
                                 title: LGLocalizedString.realEstatePromoTitleVersion7, image: #imageLiteral(resourceName: "real-estate-promo-7"))
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
