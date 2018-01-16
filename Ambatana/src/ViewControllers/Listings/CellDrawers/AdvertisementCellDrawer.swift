//
//  AdvertisementCellDrawer.swift
//  LetGo
//
//  Created by Dídac on 11/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import GoogleMobileAds

import LGCoreKit

class AdvertisementCellDrawer: BaseCollectionCellDrawer<AdvertisementCell>, GridCellDrawer {
    func willDisplay(_ model: AdvertisementData, inCell cell: AdvertisementCell) { }

    func draw(_ model: AdvertisementData, style: CellStyle, inCell cell: AdvertisementCell) {
        cell.setupWith(adData: model)
    }
}
