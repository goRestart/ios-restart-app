//
//  ListingDeckViewModelBinder.swift
//  LetGo
//
//  Created by Facundo Menzella on 26/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import LGCoreKit

final class ListingDeckViewModelBinder {
    weak var deckViewModel: ListingDeckViewModelType? = nil
    var disposeBag: DisposeBag = DisposeBag()

    func bind(to currentVM: ListingCardViewCellModel, quickChatViewModel: QuickChatViewModel) {
        guard let viewModel = deckViewModel else { return }
        self.disposeBag = DisposeBag()

        currentVM.cardListingObs.skip(1).bind { [weak viewModel] updatedListing in
            guard let strongViewModel = viewModel else { return }
            strongViewModel.replaceListingCellModelAtIndex(strongViewModel.currentIndex, withListing: updatedListing)
        }.disposed(by:disposeBag)

        currentVM.cardActionButtons.bind(to: viewModel.actionButtons).disposed(by: disposeBag)

        // TODO: chat not ready
        currentVM.cardBumpUpBannerInfo.bind(to: viewModel.bumpUpBannerInfo).disposed(by: disposeBag)
    }
}
