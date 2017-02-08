//
//  MockStickersRepository.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class MockStickersRepository: StickersRepository {

    var stickersVar = Variable<[Sticker]>([])
    var stickersResult: StickersResult?

    var stickers: Observable<[Sticker]> { return stickersVar.asObservable() }

    func show(_ completion: StickersCompletion?) {
        performAfterDelayWithCompletion(completion, result: stickersResult)
    }

    func show(typeFilter filter: StickerType?, completion: StickersCompletion?) {
        performAfterDelayWithCompletion(completion, result: stickersResult)
    }

    func sticker(_ id: String) -> Sticker? {
        return nil
    }
}
