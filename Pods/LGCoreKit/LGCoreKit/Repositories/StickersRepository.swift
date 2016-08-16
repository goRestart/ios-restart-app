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
    private var lastRetrieval: NSTimeInterval = 0

    
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
        show(typeFilter: nil, completion: completion)
    }

    /**
     Retrieves all stickers for current locale

     - parameter typeFilter: Type to filter results. nil means no filter
     - parameter completion: The completion closure
     */
    public func show(typeFilter filter: StickerType?, completion: StickersCompletion?) {
        var calledCompletion = false
        let currentRetrievalTime = NSDate().timeIntervalSince1970
        if !stickersDAO.stickers.isEmpty {
            StickersRepository.handleSuccess(stickersDAO.stickers, filter: filter, completion: completion)
            calledCompletion = true
            if currentRetrievalTime - lastRetrieval < LGCoreKitConstants.stickersRetrievalDebounceTime {
                return
            }
        }
        dataSource.show(locale) { [weak self] result in
            if let value = result.value {
                self?.stickersDAO.save(value)
                self?.lastRetrieval = currentRetrievalTime
            }
            guard !calledCompletion else { return }
            let filterCompletion: StickersCompletion = { result in
                if let value = result.value {
                    StickersRepository.handleSuccess(value, filter: filter, completion: completion)
                } else {
                    completion?(result)
                }
            }
            handleApiResult(result, completion: filterCompletion)
        }
    }

    public func sticker(id: String) -> Sticker? {
        return stickersDAO.stickers.filter{$0.name == id}.first
    }


    // MARK: - Private

    private static func handleSuccess(data: [Sticker], filter: StickerType?, completion: StickersCompletion?) {
        let resultData = filter != nil ? data.filter{$0.type == filter} : data
        completion?(StickersResult(resultData))
    }
}
