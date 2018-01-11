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
    func populateWith(productInfo: ListingVMProductInfo)
    func populateWith(socialSharer: SocialSharer)
    func populateWith(socialMessage: SocialMessage?)
    func populateWith(listingStats: ListingStats, postedDate: Date?)
    func disableStatsView()
}

final class ListingCardDetailsViewBinder {

    weak var detailsView: ListingCardDetailsViewType?
    var disposeBag: DisposeBag?

    func bind(to viewModel: ListingCardDetailsViewModel) {
        disposeBag = DisposeBag()
        guard let vmDisposeBag = disposeBag else { return }

        bindProducInfoTo(viewModel, disposeBag: vmDisposeBag)
        bindStatsTo(viewModel, disposeBag: vmDisposeBag)
        bindSocialTo(viewModel, disposeBag: vmDisposeBag)
    }

    private func bindProducInfoTo(_ viewModel: ListingCardDetailsViewModel, disposeBag: DisposeBag) {
        viewModel.cardProductInfo.unwrap().bind { [weak self] info in
            self?.detailsView?.populateWith(productInfo: info)
        }.disposed(by: disposeBag)
    }

    private func bindStatsTo(_ viewModel: ListingCardDetailsViewModel, disposeBag: DisposeBag) {
        let productCreation = viewModel.cardProductInfo.map { $0?.creationDate }
        let statsAndCreation = Observable.combineLatest(viewModel.cardProductStats.unwrap(),
                                                        productCreation) { ($0, $1) }
        let statsViewVisible: Observable<Bool> = statsAndCreation.map { (stats, creation) in
            return stats.viewsCount >= Constants.minimumStatsCountToShow
                || stats.favouritesCount >= Constants.minimumStatsCountToShow
                || creation != nil
        }
        statsViewVisible.asObservable().distinctUntilChanged().bind { [weak self] visible in
            guard !visible else { return }
            self?.detailsView?.disableStatsView()
        }.disposed(by:disposeBag)

        statsAndCreation.bind { [weak self] (stats, creation) in
            self?.detailsView?.populateWith(listingStats: stats, postedDate: creation)
        }.disposed(by:disposeBag)
    }

    func bindSocialTo(_ viewModel: ListingCardDetailsViewModel, disposeBag: DisposeBag) {
        detailsView?.populateWith(socialSharer: viewModel.cardSocialSharer)
        viewModel.cardSocialMessage.bind { [weak self] socialMessage in
            self?.detailsView?.populateWith(socialMessage: socialMessage)
        }.disposed(by:disposeBag)
    }

}
