//
//  Taxonomy+LG.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 18/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension Taxonomy {
    /*
     Gets the taxonomy color depending on its first superkeyword child ID
     */
    var color: UIColor {
        guard let firstTaxonomyChild = children.filter({$0.type == .superKeyword}).first else { return .white }
        switch firstTaxonomyChild.id {
        case 1, 2, 3, 4:
            return UIColor.Taxonomy.electronics
        case 5, 6, 7, 8:
            return UIColor.Taxonomy.family
        case 9, 10:
            return UIColor.Taxonomy.fashionAndAccessories
        case 11, 12, 13, 14, 15:
            return UIColor.Taxonomy.hobbiesAndEntertainment
        case 16, 17, 18, 19:
            return UIColor.Taxonomy.homeAndGarden
        case 20, 21, 22, 23, 24, 25:
            return UIColor.Taxonomy.vehiclesAndBicycles
        case 90:
            return UIColor.Taxonomy.others
        default:
            return UIColor.white
        }
    }
}
