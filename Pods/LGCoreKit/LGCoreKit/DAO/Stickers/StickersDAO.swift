//
//  StickersDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

protocol StickersDAO {
    var stickers: [Sticker] { get }
    func save(_ stickers: [Sticker])
}
