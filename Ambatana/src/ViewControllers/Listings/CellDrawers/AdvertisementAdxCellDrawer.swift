//
//  AdvertisementAdxCellDrawer.swift
//  LetGo
//
//  Created by Kiko Gómez on 9/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import GoogleMobileAds
import LGCoreKit

final class AdvertisementAdxCellDrawer: BaseCollectionCellDrawer<AdvertisementCell>, GridCellDrawer {
    func willDisplay(_ model: AdvertisementAdxData, inCell cell: AdvertisementCell) { }
    
    func draw(_ model: AdvertisementAdxData, style: CellStyle, inCell cell: AdvertisementCell,
              isPrivateList: Bool = false) {
        cell.setupWith(adxData: model)
    }
    
}
