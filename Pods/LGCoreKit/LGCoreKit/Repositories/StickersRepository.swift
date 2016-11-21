//
//  StickerRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldán Armengol on 13/5/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

public typealias StickersResult = Result<[Sticker], RepositoryError>
public typealias StickersCompletion = StickersResult -> Void

public protocol StickersRepository {

    var stickers: Observable<[Sticker]> { get }

    /**
     Retrieves all stickers for current locale
     
     - parameter completion: The completion closure
     */
    func show(completion: StickersCompletion?)

    /**
     Retrieves all stickers for current locale

     - parameter typeFilter: Type to filter results. nil means no filter
     - parameter completion: The completion closure
     */
    func show(typeFilter filter: StickerType?, completion: StickersCompletion?)

    func sticker(id: String) -> Sticker?
}
