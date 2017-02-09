//
//  RateBuyersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 03/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class RateBuyersViewModel: BaseViewModel {

    weak var navigator: RateBuyersNavigator?

    let possibleBuyers: [UserProduct]

    init(buyers: [UserProduct]) {
        self.possibleBuyers = buyers
    }


    // MARK: - Actions

    func closeButtonPressed() {
        navigator?.rateBuyersCancel()
    }

    func selectedBuyerAt(index: Int) {
        guard let buyer = buyerAt(index: index) else { return }
        navigator?.rateBuyersFinish(withUser: buyer)
    }

    func notOnLetgoButtonPressed() {
        navigator?.rateBuyersFinishNotOnLetgo()
    }


    // MARK: - Info 

    var buyersCount: Int {
        return possibleBuyers.count
    }

    func imageAt(index: Int) -> URL? {
        guard let buyer = buyerAt(index: index) else { return nil }
        return buyer.avatar?.fileURL
    }

    func nameAt(index: Int) -> String? {
        guard let buyer = buyerAt(index: index) else { return nil }
        return buyer.name
    }

    private func buyerAt(index: Int) -> UserProduct? {
        guard 0..<possibleBuyers.count ~= index else { return nil }
        return possibleBuyers[index]
    }
}
