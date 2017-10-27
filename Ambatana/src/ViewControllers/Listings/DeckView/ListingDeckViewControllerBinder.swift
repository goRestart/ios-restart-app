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
    let disposeBag: DisposeBag = DisposeBag()


    func bind(withViewModel viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        guard let viewController = listingDeckViewController else { return }

        bindKeyboardChanges(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindCollectionView(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindContentOffset(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindOverlaysAlpha(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindIndexSignal(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindChat(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindActions(withViewModel: viewModel, listingDeckView: listingDeckView)
    }

    private func bindActions(withViewModel viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.actionButtons.asObservable().bindNext { [unowned listingDeckView, unowned viewModel, weak self]
            actionButtons in
            guard let strongSelf = self else { return }

            guard actionButtons.count > 0 else {
                UIView.animate(withDuration: 0.2, animations: {
                    listingDeckView.itemActionsView.alpha = 0
                })
                return
            }
            let takeUntilAction = viewModel.actionButtons.asObservable().skip(1)
            guard let bottomAction = actionButtons.first else { return }
            listingDeckView.itemActionsView.topButton.configureWith(uiAction: bottomAction)
            listingDeckView.itemActionsView
                .topButton.rx.tap.takeUntil(takeUntilAction).bindNext {
                    bottomAction.action()
                }.addDisposableTo(strongSelf.disposeBag)
            UIView.animate(withDuration: 0.2, animations: {
                listingDeckView.itemActionsView.alpha = 1
            })
            }.addDisposableTo(disposeBag)
    }

    private func bindKeyboardChanges(withViewController viewController: ListingDeckViewController,
                                     viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {

        let tapGesture = UITapGestureRecognizer()
        listingDeckView.overlayView.addGestureRecognizer(tapGesture)
        tapGesture.rx.event.bindNext { _ in
            listingDeckView.chatTextView.resignFirstResponder()
            }.addDisposableTo(disposeBag)

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
        viewModel.objectChanges.observeOn(MainScheduler.instance).bindNext { [weak self] change in
            // listingDeckView.collectionView.handleCollectionChange(change)
            listingDeckView.collectionView.reloadData()
            }.addDisposableTo(disposeBag)
    }

    private func bindContentOffset(withViewController viewController: ListingDeckViewController,
                                   viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewController.contentOffset.asObservable()
            .map { [unowned listingDeckView] x in
                let pageOffset = listingDeckView.layout.pageOffset(givenOffset: x).truncatingRemainder(dividingBy: 1.0)
                if pageOffset < 0.5 {
                    return 2*pageOffset
                }
                return 2*(1 - pageOffset)
            }.bindTo(viewController.overlaysAlpha).addDisposableTo(disposeBag)

        viewController.contentOffset.asObservable().bindNext { [unowned viewController, listingDeckView] _ in
            viewController.indexSignal.value = listingDeckView.layout.page
            }.addDisposableTo(disposeBag)
    }

    private func bindOverlaysAlpha(withViewController viewController: ListingDeckViewController,
                                   viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewController.overlaysAlpha.asObservable().bindNext { [unowned listingDeckView] alpha in
            listingDeckView.updateOverlaysWith(alpha: alpha)
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
        viewModel.directChatPlaceholder.asObservable().bindTo(listingDeckView.chatTextView.rx.placeholder)
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
    
}
