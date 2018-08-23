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

final class AdvertisementDFPCellDrawer: BaseCollectionCellDrawer<AdvertisementCell>, GridCellDrawer {
    func willDisplay(_ model: AdvertisementDFPData, inCell cell: AdvertisementCell) { }

    func draw(_ model: AdvertisementDFPData, style: CellStyle, inCell cell: AdvertisementCell,
              isPrivateList: Bool = false) {
        cell.setupWith(dfpData: model)
    }
}
