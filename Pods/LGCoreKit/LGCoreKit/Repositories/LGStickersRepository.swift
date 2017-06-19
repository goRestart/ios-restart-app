//
//  LGStickersRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

final class LGStickersRepository: StickersRepository {

    var stickers: Observable<[Sticker]> {
        return stickersVar.asObservable()
    }

    let dataSource: StickersDataSource
    let stickersDAO: StickersDAO
    let locale: Locale
    private var lastRetrieval: TimeInterval = 0
    private let stickersVar: Variable<[Sticker]>


    // MARK: - Lifecycle

    init(dataSource: StickersDataSource, stickersDAO: StickersDAO,
         locale: Locale = Locale.autoupdatingCurrent) {
        self.dataSource = dataSource
        self.stickersDAO = stickersDAO
        self.locale = locale
        self.stickersVar = Variable<[Sticker]>(stickersDAO.stickers)
    }

    // MARK: - StickersRepository methods

    /**
     Retrieves all stickers for current locale

     - parameter completion: The completion closure
     */
    func show(_ completion: StickersCompletion?) {
        show(typeFilter: nil, completion: completion)
    }

    /**
     Retrieves all stickers for current locale

     - parameter typeFilter: Type to filter results. nil means no filter
     - parameter completion: The completion closure
     */
    func show(typeFilter filter: StickerType?, completion: StickersCompletion?) {
        var calledCompletion = false
        let currentRetrievalTime = Date().timeIntervalSince1970
        if !stickersDAO.stickers.isEmpty {
            LGStickersRepository.handleSuccess(stickersDAO.stickers, filter: filter, completion: completion)
            calledCompletion = true
            if currentRetrievalTime - lastRetrieval < LGCoreKitConstants.stickersRetrievalDebounceTime {
                return
            }
        }
        dataSource.show(locale) { [weak self] result in
            if let value = result.value {
                self?.stickersVar.value = value
                self?.stickersDAO.save(value)
                self?.lastRetrieval = currentRetrievalTime
            }
            guard !calledCompletion else { return }
            let filterCompletion: StickersCompletion = { result in
                if let value = result.value {
                    LGStickersRepository.handleSuccess(value, filter: filter, completion: completion)
                } else {
                    completion?(result)
                }
            }
            handleApiResult(result, completion: filterCompletion)
        }
    }

    func sticker(_ id: String) -> Sticker? {
        return stickersDAO.stickers.filter{$0.name == id}.first
    }


    // MARK: - Private

    private static func handleSuccess(_ data: [Sticker], filter: StickerType?, completion: StickersCompletion?) {
        let resultData = filter != nil ? data.filter{$0.type == filter} : data
        completion?(StickersResult(resultData))
    }
}
