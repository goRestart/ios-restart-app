//
//  StickerRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias StickersResult = Result<[Sticker], RepositoryError>
public typealias StickersCompletion = StickersResult -> Void

public final class StickersRepository {
    
    let dataSource: StickersDataSource
    let stickersDAO: StickersDAO
    let locale: NSLocale
    
    public var stickers: [Sticker] {
        return stickersDAO.stickers
    }
    
    
    // MARK: - Lifecycle
    
    init(dataSource: StickersDataSource, stickersDAO: StickersDAO,
         locale: NSLocale = NSLocale.autoupdatingCurrentLocale()) {
        self.dataSource = dataSource
        self.stickersDAO = stickersDAO
        self.locale = locale
    }
    
    // MARK: - Public methods
    
    /**
     Retrieves all stickers for current locale
     
     - parameter completion: The completion closure
     */
    public func show(completion: StickersCompletion?) {
        if !stickersDAO.stickers.isEmpty {
            completion?(StickersResult(stickersDAO.stickers))
        }
        dataSource.show(locale) { [weak self] result in
            if let value = result.value {
                self?.stickersDAO.save(value)
            }
            handleApiResult(result, completion: completion)
        }
    }
    
    public func sticker(id: String) -> Sticker? {
        return stickersDAO.stickers.filter{$0.name == id}.first
    }
}
