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

    func bindTo(listingViewModel currentVM: ListingCardViewCellModel) {
        guard let theOneViewModel = viewModel else { return }
        self.disposeBag = DisposeBag()

        currentVM.cardListingObs.skip(1).bindNext { updatedListing in
            guard let newModel = theOneViewModel.viewModelFor(listing: updatedListing) else { return }
            theOneViewModel.objects.replace(theOneViewModel.currentIndex, with: newModel)
        }.addDisposableTo(disposeBag)

        currentVM.cardStatus.bindTo(theOneViewModel.status).addDisposableTo(disposeBag)
        currentVM.cardIsShowingFeaturedStripe.bindTo(theOneViewModel.isFeatured).addDisposableTo(disposeBag)

        currentVM.cardActionButtons.bindTo(theOneViewModel.actionButtons).addDisposableTo(disposeBag)
        currentVM.cardNavBarButtons.bindTo(theOneViewModel.navBarButtons).addDisposableTo(disposeBag)
        currentVM.cardAltActions.bindTo(theOneViewModel.altActions).addDisposableTo(disposeBag)

        theOneViewModel.quickAnswers.value = currentVM.cardQuickAnswers
        currentVM.cardDirectChatEnabled.bindTo(theOneViewModel.chatEnabled).addDisposableTo(disposeBag)

        theOneViewModel.directChatMessages.removeAll()
        currentVM.cardDirectChatMessages.subscribeNext { change in
            theOneViewModel.performCollectionChange(change: change)
        }.addDisposableTo(disposeBag)
        theOneViewModel.directChatPlaceholder.value = currentVM.cardDirectChatPlaceholder

        currentVM.cardBumpUpBannerInfo.bindTo(theOneViewModel.bumpUpBannerInfo).addDisposableTo(disposeBag)
    }
}
