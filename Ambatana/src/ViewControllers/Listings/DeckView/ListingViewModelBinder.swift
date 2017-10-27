//
//  ListingViewModelBinder.swift
//  LetGo
//
//  Created by Facundo Menzella on 26/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

final class ListingViewModelBinder {

    // the one to rule them all
    let viewModel: ListingDeckViewModel? = nil
    var disposeBag: DisposeBag = DisposeBag()

    func bindTo(listingViewModel currentVM: ListingViewModel) {
        guard let theOneViewModel = viewModel else { return }
        self.disposeBag = DisposeBag()

        currentVM.listing.asObservable().skip(1).bindNext { [weak self] updatedListing in
            //            theOneViewModel.currentViewModelIsBeingUpdated.value = true
            //            theOneViewModel.objects.replace(index, with: ListingCarouselCellModel(listing:updatedListing))
            //            theOneViewModel.currentViewModelIsBeingUpdated.value = false
            }.addDisposableTo(disposeBag)

        currentVM.status.asObservable().bindTo(theOneViewModel.status).addDisposableTo(disposeBag)
        currentVM.isShowingFeaturedStripe.asObservable().bindTo(theOneViewModel.isFeatured).addDisposableTo(disposeBag)

        currentVM.productInfo.asObservable().bindTo(theOneViewModel.productInfo).addDisposableTo(disposeBag)
        currentVM.productImageURLs.asObservable().bindTo(theOneViewModel.productImageURLs).addDisposableTo(disposeBag)
        currentVM.userInfo.asObservable().bindTo(theOneViewModel.userInfo).addDisposableTo(disposeBag)
        currentVM.listingStats.asObservable().bindTo(theOneViewModel.listingStats).addDisposableTo(disposeBag)

        currentVM.actionButtons.asObservable().bindTo(theOneViewModel.actionButtons).addDisposableTo(disposeBag)
        currentVM.navBarButtons.asObservable().bindTo(theOneViewModel.navBarButtons).addDisposableTo(disposeBag)

        theOneViewModel.quickAnswers.value = currentVM.quickAnswers
        currentVM.directChatEnabled.asObservable().bindTo(theOneViewModel.quickAnswersAvailable).addDisposableTo(disposeBag)

        currentVM.directChatEnabled.asObservable().bindTo(theOneViewModel.directChatEnabled).addDisposableTo(disposeBag)
        theOneViewModel.directChatMessages.removeAll()
        currentVM.directChatMessages.changesObservable.subscribeNext { [unowned self] change in
            //            theOneViewModel.performCollectionChange(change: change)
            }.addDisposableTo(disposeBag)
        theOneViewModel.directChatPlaceholder.value = currentVM.directChatPlaceholder

        currentVM.isFavorite.asObservable().bindTo(theOneViewModel.isFavorite).addDisposableTo(disposeBag)
        currentVM.favoriteButtonState.asObservable().bindTo(theOneViewModel.favoriteButtonState).addDisposableTo(disposeBag)
        currentVM.shareButtonState.asObservable().bindTo(theOneViewModel.shareButtonState).addDisposableTo(disposeBag)
        currentVM.bumpUpBannerInfo.asObservable().bindTo(theOneViewModel.bumpUpBannerInfo).addDisposableTo(disposeBag)

        currentVM.socialMessage.asObservable().bindTo(theOneViewModel.socialMessage).addDisposableTo(disposeBag)
        theOneViewModel.socialSharer.value = currentVM.socialSharer
    }
}
