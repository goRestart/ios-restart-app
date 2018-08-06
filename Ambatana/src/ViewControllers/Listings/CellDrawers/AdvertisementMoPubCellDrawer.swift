//
//  AdvertisementMoPubCellDrawer.swift
//  LetGo
//
//  Created by Kiko Gómez on 22/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import MoPub
import LGCoreKit

final class AdvertisementMoPubCellDrawer: BaseCollectionCellDrawer<AdvertisementCell>, GridCellDrawer {
    func willDisplay(_ model: AdvertisementMoPubData, inCell cell: AdvertisementCell) { }
    
    func draw(_ model: AdvertisementMoPubData, style: CellStyle, inCell cell: AdvertisementCell,
              isPrivateList: Bool = false) {
        cell.setupWith(moPubData: model)
    }

}
