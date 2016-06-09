//
//  StickersDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

typealias StickersDataSourceResult = Result<[Sticker], ApiError>
typealias StickersDataSourceCompletion = StickersDataSourceResult -> Void

protocol StickersDataSource {
    func show(locale: NSLocale, completion: StickersDataSourceCompletion?)
}
