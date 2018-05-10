//
//  ListingDeckViewControllerBinder.swift
//  LetGo
//
//  Created by Facundo Menzella on 27/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxCocoa
import RxSwift

protocol ListingDeckViewControllerBinderType: class {
    var keyboardChanges: Observable<KeyboardChange> { get }
    var rxContentOffset: Observable<CGPoint> { get }
    var rxDidBeginEditing: ControlEvent<()>? { get }
    var rxDidEndEditing: ControlEvent<()>? { get }

    func updateWith(keyboardChange: KeyboardChange)
    func updateWithBumpUpInfo(_ bumpInfo: BumpUpInfo?)

    func didTapShare()
    func didTapCardAction()
    func didTapOnUserIcon()

    func willDisplayCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath)
    func willBeginDragging()
    func didMoveToItemAtIndex(_ index: Int)
    func didEndDecelerating()
    
    func updateViewWith(alpha: CGFloat, chatEnabled: Bool, actionsEnabled: Bool)
    func updateViewWithActions(_ actions: [UIAction])

    func turnNavigationBar(_ on: Bool)
}

protocol ListingDeckViewType: class {
    var rxCollectionView: Reactive<UICollectionView> { get }
    var rxActionButton: Reactive<LetgoButton> { get }
    var rxStartPlayingButton: Reactive<UIButton> { get }
    var currentPage: Int { get }
    func normalizedPageOffset(givenOffset: CGFloat) -> CGFloat

    func handleCollectionChange<T>(_ change: CollectionChange<T>, completion: ((Bool) -> Void)?)
}

protocol ListingDeckViewModelType: class {
    var quickChatViewModel: QuickChatViewModel { get }
    var currentIndex: Int { get }
    var userHasScrolled: Bool { get set }

    var actionButtons: Variable<[UIAction]> { get }
    var rxActionButtons: Observable<[UIAction]> { get }

    var bumpUpBannerInfo: Variable<BumpUpInfo?> { get }
    var rxBumpUpBannerInfo: Observable<BumpUpInfo?> { get }

    var rxObjectChanges: Observable<CollectionChange<ListingCellModel>> { get }
    var rxIsChatEnabled: Observable<Bool> { get }

    func replaceListingCellModelAtIndex(_ index: Int, withListing listing: Listing)
    func moveToListingAtIndex(_ index: Int, movement: DeckMovement)
    func openVideoPlayer()
}

protocol ListingDeckViewControllerBinderCellType {
    var rxShareButton: Reactive<UIButton> { get }
    var rxActionButton: Reactive<UIButton> { get }
    var rxUserIcon: Reactive<UIButton> { get }
    var disposeBag: DisposeBag { get }

    func recycleDisposeBag()
}

final class ListingDeckViewControllerBinder {

    weak var listingDeckViewController: ListingDeckViewControllerBinderType? = nil
    fileprivate(set) var disposeBag: DisposeBag?

    func bind(withViewModel viewModel: ListingDeckViewModelType, listingDeckView: ListingDeckViewType) {
        guard let viewController = listingDeckViewController else { return }
        let currentDB = DisposeBag()
        disposeBag = currentDB

        bindKeyboardChanges(withViewController: viewController, disposeBag: currentDB)
        bindCollectionView(withViewController: viewController, viewModel: viewModel,
                           listingDeckView: listingDeckView, disposeBag: currentDB)
        bindDeckMovement(withViewController: viewController, viewModel: viewModel,
                          listingDeckView: listingDeckView, disposeBag: currentDB)
        bindChat(withViewController: viewController, viewModel: viewModel,
                 listingDeckView: listingDeckView, disposeBag: currentDB)
        bindActions(withViewModel: viewModel, listingDeckView: listingDeckView, disposeBag: currentDB)
        bindNavigationBar(withViewController: viewController, listingDeckView: listingDeckView, disposeBag: currentDB)
        bindBumpUps(withViewModel: viewModel, viewController: viewController, listingDeckView: listingDeckView, disposeBag: currentDB)
    }

    func bindNavigationBar(withViewController
        viewController: ListingDeckViewControllerBinderType,
                           listingDeckView: ListingDeckViewType,
                           disposeBag: DisposeBag) {
        if let didEndEditing = viewController.rxDidEndEditing {
            didEndEditing
                .asDriver()
                .drive(onNext: { [weak viewController] _ in
                    viewController?.turnNavigationBar(true)
                }).disposed(by: disposeBag)
        }
        if let didBeginEditing = viewController.rxDidBeginEditing {
            didBeginEditing
                .asDriver()
                .drive(onNext: { [weak viewController] _ in
                    viewController?.turnNavigationBar(false)
                }).disposed(by: disposeBag)
        }
    }

    func bind(cell: ListingDeckViewControllerBinderCellType) {
        guard let viewController = listingDeckViewController else { return }
        cell.recycleDisposeBag()
        cell.rxShareButton.tap.asObservable().bind { [weak viewController] in
            viewController?.didTapShare()
        }.disposed(by: cell.disposeBag)

        cell.rxActionButton.tap.asObservable().bind { [weak viewController] in
            viewController?.didTapCardAction()
        }.disposed(by: cell.disposeBag)

        cell.rxUserIcon.tap.asObservable().bind { [weak viewController] in
            viewController?.didTapOnUserIcon()
        }.disposed(by: cell.disposeBag)
    }

    private func bindActions(withViewModel viewModel: ListingDeckViewModelType,
                             listingDeckView: ListingDeckViewType,
                             disposeBag: DisposeBag) {
        viewModel.rxActionButtons.bind { [weak self] actionButtons in
            self?.listingDeckViewController?.updateViewWithActions(actionButtons)
            self?.bindActionButtonTap(withActions: actionButtons,
                                      listingDeckView: listingDeckView, disposeBag: disposeBag)
        }.disposed(by: disposeBag)

        listingDeckView.rxStartPlayingButton.tap.bind { [weak viewModel] in
            viewModel?.openVideoPlayer()
        }.disposed(by: disposeBag)
    }

    private func bindActionButtonTap(withActions actionButtons: [UIAction],
                                     listingDeckView: ListingDeckViewType?,
                                     disposeBag: DisposeBag) {
        guard let actionButton = actionButtons.first else { return }
        listingDeckView?.rxActionButton.tap.bind {
            actionButton.action()
        }.disposed(by: disposeBag)
    }

    private func bindKeyboardChanges(withViewController viewController: ListingDeckViewControllerBinderType,
                                     disposeBag: DisposeBag) {
        viewController.keyboardChanges.bind { [weak viewController] change in
            viewController?.updateWith(keyboardChange: change)
        }.disposed(by: disposeBag)
    }

    private func bindBumpUps(withViewModel viewModel: ListingDeckViewModelType,
                             viewController: ListingDeckViewControllerBinderType,
                             listingDeckView: ListingDeckViewType,
                             disposeBag: DisposeBag) {
        let didEndDecelerating = listingDeckView.rxCollectionView.didEndDecelerating
        let bumpUp = viewModel.bumpUpBannerInfo.asObservable().share()
        let willBeginDragging = listingDeckView.rxCollectionView.willBeginDragging

        bumpUp
            .filter { $0 != nil }
            .takeUntil(willBeginDragging.asObservable())
            .bind { [weak viewController] bumpInfo in
                viewController?.updateWithBumpUpInfo(bumpInfo)
            }.disposed(by: disposeBag)

        Observable
            .combineLatest(didEndDecelerating, bumpUp) { ($0, $1) }
            .bind { [weak viewController] (didEnded, bumpInfo) in
                viewController?.updateWithBumpUpInfo(bumpInfo)
            }.disposed(by: disposeBag)
    }

    private func bindCollectionView(withViewController viewController: ListingDeckViewControllerBinderType,
                                    viewModel: ListingDeckViewModelType, listingDeckView: ListingDeckViewType,
                                    disposeBag: DisposeBag) {
        viewModel.rxObjectChanges
            .observeOn(MainScheduler.instance)
            .bind { [weak listingDeckView] change in
            listingDeckView?.handleCollectionChange(change, completion: nil)
        }.disposed(by: disposeBag)

        let willBeginDragging = listingDeckView.rxCollectionView.willBeginDragging
        let didEndDecelerating = listingDeckView.rxCollectionView.didEndDecelerating

        willBeginDragging
            .asDriver().drive(onNext: { [weak viewController] _ in
                viewController?.willBeginDragging()
        }).disposed(by: disposeBag)

        didEndDecelerating.asDriver()
            .drive(onNext: { [weak viewController] _ in
            viewController?.didEndDecelerating()
        }).disposed(by: disposeBag)

        listingDeckView.rxCollectionView.willDisplayCell.bind { [weak viewController] (cell, indexPath) in
            viewController?.willDisplayCell(cell, atIndexPath: indexPath)
        }.disposed(by: disposeBag)
    }

    private func bindDeckMovement(withViewController viewController: ListingDeckViewControllerBinderType,
                                   viewModel: ListingDeckViewModelType, listingDeckView: ListingDeckViewType,
                                   disposeBag: DisposeBag) {
        let pageSignal: Observable<Int> = viewController.rxContentOffset.map { [weak listingDeckView] _ in
            return listingDeckView?.currentPage ?? 0
        }
        pageSignal.skip(1).distinctUntilChanged().bind { [weak viewModel, weak viewController] page in
            viewController?.didMoveToItemAtIndex(page)
            if let currentIndex = viewModel?.currentIndex, currentIndex < page {
                viewModel?.moveToListingAtIndex(page, movement: .swipeRight)
            } else if let currentIndex = viewModel?.currentIndex, currentIndex > page {
                viewModel?.moveToListingAtIndex(page, movement: .swipeLeft)
            }
        }.disposed(by: disposeBag)
    }

    private func bindChat(withViewController viewController: ListingDeckViewControllerBinderType,
                          viewModel: ListingDeckViewModelType, listingDeckView: ListingDeckViewType,
                          disposeBag: DisposeBag) {
        viewController.rxContentOffset.skip(1).bind { [weak viewModel] _ in
            viewModel?.userHasScrolled = true
        }.disposed(by: disposeBag)

        let contentOffsetAlphaSignal: Observable<CGFloat> = viewController.rxContentOffset
            .map { [weak listingDeckView] point in
                let pageOffset = listingDeckView?.normalizedPageOffset(givenOffset: point.x)
                                                .truncatingRemainder(dividingBy: 1.0) ?? 0.5
                guard pageOffset >= 0.5 else {
                    return 2*pageOffset
                }
                return 2*(1 - pageOffset)   
        }.distinctUntilChanged()

        let areActionsEnabled = viewModel.rxActionButtons.map { $0.count > 0 }
        let chatEnabled: Observable<Bool> = viewModel.rxIsChatEnabled.distinctUntilChanged()
        Observable.combineLatest(contentOffsetAlphaSignal,
                                 chatEnabled,
                                 areActionsEnabled.distinctUntilChanged()) { ($0, $1, $2) }
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak viewController] (offsetAlpha, isChatEnabled, actionsEnabled) in
                viewController?.updateViewWith(alpha: offsetAlpha,
                                               chatEnabled: isChatEnabled,
                                               actionsEnabled: actionsEnabled)
        }.disposed(by: disposeBag)
    }
}
