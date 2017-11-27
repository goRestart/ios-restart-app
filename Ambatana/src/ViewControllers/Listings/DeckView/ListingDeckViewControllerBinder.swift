//
//  ListingDeckViewControllerBinder.swift
//  LetGo
//
//  Created by Facundo Menzella on 27/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

final class ListingDeckViewControllerBinder {

    weak var listingDeckViewController: ListingDeckViewController? = nil
    var disposeBag = DisposeBag()
    var currentDisposeBag: DisposeBag?

    func bind(withViewModel viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        guard let viewController = listingDeckViewController else { return }

        bindKeyboardChanges(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindCollectionView(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindContentOffset(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindOverlaysAlpha(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindIndexSignal(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindChat(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindActions(withViewModel: viewModel, listingDeckView: listingDeckView)
        bindAltActions(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindNavigationBarActions(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindBumpUp(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
    }

    private func bindActions(withViewModel viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.actionButtons.asObservable().bindNext { [unowned listingDeckView, weak self]
            actionButtons in
            guard let strongSelf = self else { return }

            guard actionButtons.count > 0 else {
                listingDeckView.hideActions()
                return
            }
            guard let actionButton = actionButtons.first else { return }
            listingDeckView.itemActionsView.actionButton.configureWith(uiAction: actionButton)
            listingDeckView.itemActionsView
                .actionButton.rx.tap.bindNext {
                    actionButton.action()
                }.addDisposableTo(strongSelf.disposeBag)
            UIView.animate(withDuration: 0.2, animations: {
                listingDeckView.showActions()
            })
        }.addDisposableTo(disposeBag)
    }

    private func bindBumpUp(withViewController viewController: ListingDeckViewController,
                            viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.bumpUpBannerInfo.asObservable().bindNext { [unowned viewController] bumpInfo in
            guard let bumpUp = bumpInfo else { return }
            viewController.showBumpUpBanner(bumpInfo: bumpUp)
        }.addDisposableTo(disposeBag)
    }

    private func bindAltActions(withViewController viewController: ListingDeckViewController,
                                viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.altActions.asObservable().skip(1).bindNext { [unowned viewController] altActions in
            guard altActions.count > 0 else { return }
            viewController.vmShowOptions(LGLocalizedString.commonCancel, actions: altActions)
        }.addDisposableTo(disposeBag)
    }

    private func bindKeyboardChanges(withViewController viewController: ListingDeckViewController,
                                     viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewController.keyboardChanges.bindNext { [unowned viewController] change in
            let height = listingDeckView.bounds.height - change.origin
            listingDeckView.updateBottom(wintInset: height)
            UIView.animate(withDuration: TimeInterval(change.animationTime),
                           delay: 0,
                           options: change.animationOptions,
                           animations: {
                            if change.visible {
                                listingDeckView.showFullScreenChat()
                            } else {
                                listingDeckView.hideFullScreenChat()
                            }
                            viewController.view.layoutIfNeeded()
            }, completion: nil)
        }.addDisposableTo(disposeBag)
    }

    private func bindCollectionView(withViewController viewController: ListingDeckViewController,
                                    viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.objectChanges.observeOn(MainScheduler.instance).bindNext { [unowned listingDeckView] change in
            listingDeckView.collectionView.handleCollectionChange(change)
        }.addDisposableTo(disposeBag)
    }

    private func bindContentOffset(withViewController viewController: ListingDeckViewController,
                                   viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewController.contentOffset.asObservable()
            .map { [unowned listingDeckView] x in
                let pageOffset = listingDeckView.collectionLayout.pageOffset(givenOffset: x).truncatingRemainder(dividingBy: 1.0)
                guard pageOffset >= 0.5 else {
                    return 2*pageOffset
                }
                return 2*(1 - pageOffset)
            }.bindTo(viewController.overlaysAlpha)
        .addDisposableTo(disposeBag)

        viewController.contentOffset.asObservable().bindNext { [unowned viewController, listingDeckView] _ in
            viewController.indexSignal.value = listingDeckView.collectionLayout.page
        }.addDisposableTo(disposeBag)
    }

    private func bindOverlaysAlpha(withViewController viewController: ListingDeckViewController,
                                   viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewController.overlaysAlpha.asObservable().bindNext { [unowned viewController] alpha in
            viewController.updateViewWith(alpha: alpha)
        }.addDisposableTo(disposeBag)
    }

    private func bindIndexSignal(withViewController viewController: ListingDeckViewController,
                                 viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewController.indexSignal.asObservable().distinctUntilChanged().bindNext { [unowned viewModel] index in
            viewModel.moveToProductAtIndex(index, movement: .swipeRight)
        }.addDisposableTo(disposeBag)
    }

    private func bindChat(withViewController viewController: ListingDeckViewController,
                          viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.directChatPlaceholder.asObservable()
            .bindTo(listingDeckView.chatTextView.rx.placeholder)
            .addDisposableTo(disposeBag)
        if let productVM = viewModel.currentListingViewModel, !productVM.areQuickAnswersDynamic {
            listingDeckView.chatTextView.setInitialText(LGLocalizedString.chatExpressTextFieldText)
        }

        viewModel.quickAnswers.asObservable().bindNext { [unowned listingDeckView, unowned viewModel] quickAnswers in
            let isDynamic = viewModel.currentListingViewModel?.areQuickAnswersDynamic ?? false
            listingDeckView.directAnswersView.update(answers: quickAnswers, isDynamic: isDynamic)
        }.addDisposableTo(disposeBag)

        viewModel.chatEnabled.asObservable().bindNext { [unowned listingDeckView] enabled in
            if enabled {
                listingDeckView.showChat()
                listingDeckView.hideActions()
            } else {
                listingDeckView.hideChat()
                listingDeckView.showActions()
            }

        }.addDisposableTo(disposeBag)

        viewModel.directChatMessages.changesObservable.bindNext { [unowned listingDeckView, unowned viewModel] change in
            switch change {
            case .insert(_, let message):
                // if the message is already in the table we don't perform animations
                let chatMessageExists = viewModel.directChatMessages.value
                    .filter({ $0.objectId == message.objectId }).count >= 1
                listingDeckView.directChatTable.handleCollectionChange(change,
                                                                       animation: chatMessageExists
                                                                        ? .none : .top)
            default:
                listingDeckView.directChatTable.handleCollectionChange(change, animation: .none)
            }
        }.addDisposableTo(disposeBag)
    }

    private func bindNavigationBarActions(withViewController viewController: ListingDeckViewController,
                                          viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }
            viewController.setNavigationBarRightButtons([])
            guard navBarButtons.count > 0, let action = navBarButtons.first else { return }
            viewController.setLetGoRightButtonWith(action, buttonTintColor: .red,
                                                   tapBlock: { tapEvent in
                                                    tapEvent.bindNext{
                                                        action.action()
                                                        }.addDisposableTo(strongSelf.disposeBag)
            })
        }.addDisposableTo(disposeBag)
    }
    
}
