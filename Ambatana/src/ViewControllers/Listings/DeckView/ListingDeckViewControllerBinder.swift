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
        bindChat(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindActions(withViewModel: viewModel, listingDeckView: listingDeckView)
        bindAltActions(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindNavigationBarActions(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
        bindBumpUp(withViewController: viewController, viewModel: viewModel, listingDeckView: listingDeckView)
    }

    func bind(cell: ListingCardView) {
        guard let viewController = listingDeckViewController else { return }
        cell.rxShareButton.tap.asObservable().bind {
            viewController.didTapShare()
        }.disposed(by: cell.disposeBag)

        cell.rxActionButton.tap.asObservable().bind {
            viewController.didTapCardAction()
        }.disposed(by: cell.disposeBag)
    }

    private func bindActions(withViewModel viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.actionButtons.asObservable().bind { [unowned listingDeckView, weak self]
            actionButtons in
            guard let strongSelf = self else { return }

            guard actionButtons.count > 0 else {
                listingDeckView.hideActions()
                return
            }
            guard let actionButton = actionButtons.first else { return }
            listingDeckView.configureActionWith(actionButton)
            listingDeckView.rx_actionButton.tap.bind {
                actionButton.action()
            }.disposed(by: strongSelf.disposeBag)
            UIView.animate(withDuration: 0.2, animations: {
                listingDeckView.showActions()
            })
        }.disposed(by: disposeBag)
    }

    private func bindBumpUp(withViewController viewController: ListingDeckViewController,
                            viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.bumpUpBannerInfo.asObservable().bind { [unowned viewController] bumpInfo in
            guard let bumpUp = bumpInfo else { return }
            viewController.showBumpUpBanner(bumpInfo: bumpUp)
        }.disposed(by: disposeBag)
    }

    private func bindAltActions(withViewController viewController: ListingDeckViewController,
                                viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.altActions.asObservable().skip(1).bind { [unowned viewController] altActions in
            guard altActions.count > 0 else { return }
            viewController.vmShowOptions(LGLocalizedString.commonCancel, actions: altActions)
        }.disposed(by: disposeBag)
    }

    private func bindKeyboardChanges(withViewController viewController: ListingDeckViewController,
                                     viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewController.keyboardChanges.bind { [unowned viewController] change in
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
        }.disposed(by: disposeBag)
    }

    private func bindCollectionView(withViewController viewController: ListingDeckViewController,
                                    viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.objectChanges.observeOn(MainScheduler.instance).bind { [unowned listingDeckView] change in
            listingDeckView.collectionView.handleCollectionChange(change)
        }.disposed(by: disposeBag)
    }

    private func bindContentOffset(withViewController viewController: ListingDeckViewController,
                                   viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        let pageSignal: Observable<Int> = viewController.contentOffset.map { _ in return listingDeckView.currentPage }
        pageSignal.distinctUntilChanged().skip(1).bind { [weak viewModel] page in
            // TODO: Tracking 3109
            viewModel?.moveToProductAtIndex(page, movement: .swipeRight)
        }.disposed(by: disposeBag)

        pageSignal.distinctUntilChanged().bind { [weak viewController] page in
            viewController?.pageDidChange(current: page)
        }.disposed(by: disposeBag)
    }

    private func bindChat(withViewController viewController: ListingDeckViewController,
                          viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        if let rx_chatTextView = listingDeckView.rx_chatTextView {
            viewModel.quickChatViewModel.directChatPlaceholder.asObservable()
                .bind(to: rx_chatTextView.placeholder)
                .disposed(by: disposeBag)
        }
        
        let contentOffsetAlphaSignal: Observable<CGFloat> = viewController.contentOffset
            .map { [unowned listingDeckView] x in
                let pageOffset = listingDeckView.pageOffset(givenOffset: x).truncatingRemainder(dividingBy: 1.0)
                guard pageOffset >= 0.5 else {
                    return 2*pageOffset
                }
                return 2*(1 - pageOffset)
        }.asObservable()
        
        let chatEnabled: Observable<Bool> = viewModel.quickChatViewModel.chatEnabled.asObservable()
        Observable.combineLatest(contentOffsetAlphaSignal,
                                 chatEnabled.distinctUntilChanged()) { ($0, $1) }
            .bind { [weak listingDeckView] (offsetAlpha, isChatEnabled) in
                if isChatEnabled {
                    viewController.updateViewWith(alpha: offsetAlpha)
                } else {
                    listingDeckView?.hideChat()
                    listingDeckView?.showActions()
                }
            }.disposed(by: disposeBag)
    }

    private func bindNavigationBarActions(withViewController viewController: ListingDeckViewController,
                                          viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }
            viewController.setNavigationBarRightButtons([])
            guard navBarButtons.count > 0, let action = navBarButtons.first else { return }
            viewController.setLetGoRightButtonWith(action, buttonTintColor: .red,
                                                   tapBlock: { tapEvent in
                                                    tapEvent.bind { action.action() }
                                                    .disposed(by:strongSelf.disposeBag)
            })
        }.disposed(by: disposeBag)
    }
    
}
