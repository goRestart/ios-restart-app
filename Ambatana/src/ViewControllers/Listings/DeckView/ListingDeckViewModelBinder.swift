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

    func bindTo(listingViewModel currentVM: ListingCardViewCellModel, quickChatViewModel: QuickChatViewModel) {
        guard let theOneViewModel = viewModel else { return }
        self.disposeBag = DisposeBag()

        currentVM.cardListingObs.skip(1).bindNext { updatedListing in
            guard let newModel = theOneViewModel.viewModelFor(listing: updatedListing) else { return }
            theOneViewModel.objects.replace(theOneViewModel.currentIndex, with: newModel)
        }.addDisposableTo(disposeBag)

        currentVM.cardActionButtons.bindTo(theOneViewModel.actionButtons).addDisposableTo(disposeBag)
        currentVM.cardNavBarButtons.bindTo(theOneViewModel.navBarButtons).addDisposableTo(disposeBag)
        currentVM.cardAltActions.bindTo(theOneViewModel.altActions).addDisposableTo(disposeBag)
        bind(listingViewModel: currentVM, quickChatViewModel: quickChatViewModel)

        currentVM.cardBumpUpBannerInfo.bindTo(theOneViewModel.bumpUpBannerInfo).addDisposableTo(disposeBag)
    }

    private func bind(listingViewModel currentVM: ListingCardViewCellModel, quickChatViewModel: QuickChatViewModel) {
        quickChatViewModel.quickAnswers.value = currentVM.cardQuickAnswers
        currentVM.cardDirectChatEnabled.bindTo(quickChatViewModel.chatEnabled).addDisposableTo(disposeBag)

        quickChatViewModel.directChatMessages.removeAll()
        currentVM.cardDirectChatMessages.subscribeNext { change in
            quickChatViewModel.performCollectionChange(change: change)
        }.addDisposableTo(disposeBag)
        quickChatViewModel.directChatPlaceholder.value = currentVM.cardDirectChatPlaceholder
    }
}
