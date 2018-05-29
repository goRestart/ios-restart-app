//
//  ListingCardDetailsViewBinder.swift
//  LetGo
//
//  Created by Facundo Menzella on 21/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

protocol ListingCardDetailsViewType: class {
    func populateWith(productInfo: ListingVMProductInfo?, showExactLocationOnMap: Bool)
    func populateWith(socialSharer: SocialSharer)
    func populateWith(socialMessage: SocialMessage?)
    func populateWith(listingStats: ListingStats?, postedDate: Date?)
}

final class ListingCardDetailsViewBinder {

    weak var detailsView: ListingCardDetailsViewType?
    var disposeBag: DisposeBag?

    func recycleDisposeBag() {
        disposeBag = DisposeBag()
    }

    func bind(to viewModel: ListingCardDetailsViewModel) {
        recycleDisposeBag()
        guard let vmDisposeBag = disposeBag else { return }

        bindProducInfoTo(viewModel, disposeBag: vmDisposeBag)
        bindStatsTo(viewModel, disposeBag: vmDisposeBag)
        bindSocialTo(viewModel, disposeBag: vmDisposeBag)
    }

    private func bindProducInfoTo(_ viewModel: ListingCardDetailsViewModel, disposeBag: DisposeBag) {
        let productInfoObservable = Observable
            .combineLatest(viewModel.cardProductInfo.unwrap().observeOn(MainScheduler.asyncInstance),
                           viewModel.cardShowExactLocationOnMap.observeOn(MainScheduler.asyncInstance)) { ($0, $1) }

        productInfoObservable.observeOn(MainScheduler.asyncInstance).bind { [weak self] (info, showExactLocationOnMap) in
            self?.detailsView?.populateWith(productInfo: info, showExactLocationOnMap: showExactLocationOnMap)
            }.disposed(by: disposeBag)
    }

    private func bindStatsTo(_ viewModel: ListingCardDetailsViewModel, disposeBag: DisposeBag) {
        let productCreation = viewModel.cardProductInfo.map { $0?.creationDate }
        let stats = viewModel.cardProductStats.unwrap().distinctUntilChanged({ (lhs, rhs) -> Bool in
            return lhs.favouritesCount != rhs.favouritesCount || lhs.viewsCount != rhs.viewsCount
        })
        let statsAndCreation = Observable.combineLatest(stats, productCreation) { ($0, $1) }
        statsAndCreation.observeOn(MainScheduler.asyncInstance).bind { [weak self] (stats, creation) in
            self?.detailsView?.populateWith(listingStats: stats, postedDate: creation)
        }.disposed(by:disposeBag)
    }

    func bindSocialTo(_ viewModel: ListingCardDetailsViewModel, disposeBag: DisposeBag) {
        detailsView?.populateWith(socialSharer: viewModel.cardSocialSharer)
        viewModel.cardSocialMessage.observeOn(MainScheduler.asyncInstance).bind { [weak self] socialMessage in
            self?.detailsView?.populateWith(socialMessage: socialMessage)
        }.disposed(by:disposeBag)
    }
}
