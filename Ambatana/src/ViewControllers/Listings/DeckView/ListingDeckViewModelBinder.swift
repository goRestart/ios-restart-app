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
    weak var viewModel: ListingDeckViewModel? = nil
    var disposeBag: DisposeBag = DisposeBag()

    func bind(to currentVM: ListingCardViewCellModel, quickChatViewModel: QuickChatViewModel) {
        guard let theOneViewModel = viewModel else { return }
        self.disposeBag = DisposeBag()

        currentVM.cardListingObs.skip(1).bind { updatedListing in
            theOneViewModel.replaceListingCellModelAtIndex(theOneViewModel.currentIndex, withListing: updatedListing)
        }.disposed(by:disposeBag)

        currentVM.cardActionButtons.bind(to: theOneViewModel.actionButtons).disposed(by: disposeBag)
        currentVM.cardNavBarButtons.bind(to: theOneViewModel.navBarButtons).disposed(by: disposeBag)
        currentVM.cardAltActions.bind(to: theOneViewModel.altActions).disposed(by: disposeBag)

        bind(listingViewModel: currentVM, quickChatViewModel: quickChatViewModel)
        currentVM.cardBumpUpBannerInfo.bind(to: theOneViewModel.bumpUpBannerInfo).disposed(by: disposeBag)
    }

    private func bind(listingViewModel currentVM: ListingCardViewCellModel, quickChatViewModel: QuickChatViewModel) {
        quickChatViewModel.quickAnswers.value = currentVM.cardQuickAnswers
        currentVM.cardDirectChatEnabled.bind(to: quickChatViewModel.chatEnabled).disposed(by: disposeBag)

        quickChatViewModel.directChatMessages.removeAll()
        
        currentVM.cardDirectChatMessages.subscribeNext { change in
            quickChatViewModel.performCollectionChange(change: change)
        }.disposed(by:disposeBag)
        quickChatViewModel.directChatPlaceholder.value = currentVM.cardDirectChatPlaceholder
    }
}
