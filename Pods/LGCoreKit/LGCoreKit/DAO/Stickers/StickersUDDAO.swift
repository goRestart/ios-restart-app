//
//  StickersUDDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

final class StickersUDDAO: StickersDAO {
    static let StickersKey = "StickersUDKey"
    var stickers: [Sticker] = []
    let userDefaults: NSUserDefaults
    
    
    // MARK: - Lifecycle
    
    init(userDefaults: NSUserDefaults) {
        self.userDefaults = userDefaults
        self.stickers = fetch()
    }
    
    func save(stickers: [Sticker]) {
        self.stickers = stickers
        let array = stickers.map{$0.encode()}
        userDefaults.setValue(Array(array), forKey: StickersUDDAO.StickersKey)
    }
    
    
    // MARK: - Private methods
    
    /**
     Return the stickers stored in UserDefaults
    */
    private func fetch() -> [Sticker] {
        guard let array = userDefaults.arrayForKey(StickersUDDAO.StickersKey) as? [[String: AnyObject]] else {
            return [] }
        return  array.flatMap { LGSticker.decode($0) }
    }
}
