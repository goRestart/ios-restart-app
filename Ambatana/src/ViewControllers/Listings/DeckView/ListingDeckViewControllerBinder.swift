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

    func updateWith(keyboardChange: KeyboardChange)
    func showBumpUpBanner(bumpInfo: BumpUpInfo)
    func closeBumpUpBanner()
    func didTapShare()
    func didTapCardAction()
    func didTapOnUserIcon()
    func updateSideCells()
    func updateViewWith(alpha: CGFloat, chatEnabled: Bool, isMine: Bool, actionsEnabled: Bool)
    func blockSideInteractions()
    func updateViewWithActions(_ actions: [UIAction])

    func setupPageCurrentCell()
}

protocol ListingDeckViewType: class {
    var collectionView: UICollectionView { get }
    var rxActionButton: Reactive<UIButton> { get }
    var currentPage: Int { get }
    func pageOffset(givenOffset: CGFloat) -> CGFloat
}

protocol ListingDeckViewModelType: class {
    var quickChatViewModel: QuickChatViewModel { get }
    var currentIndex: Int { get }
    var actionButtons: Variable<[UIAction]> { get }
    var rxActionButtons: Observable<[UIAction]> { get }

    var bumpUpBannerInfo: Variable<BumpUpInfo?> { get }
    var rxBumpUpBannerInfo: Observable<BumpUpInfo?> { get }

    var rxObjectChanges: Observable<CollectionChange<ListingCellModel>> { get }
    var rxIsChatEnabled: Observable<Bool> { get }
    var rxIsMine: Observable<Bool> { get }

    var userHasScrolled: Bool { get set }

    func moveToProductAtIndex(_ index: Int, movement: CarouselMovement)
    func replaceListingCellModelAtIndex(_ index: Int, withListing listing: Listing)
}

protocol ListingDeckViewControllerBinderCellType {
    var rxShareButton: Reactive<UIButton> { get }
    var rxActionButton: Reactive<UIButton> { get }
    var rxUserIcon: Reactive<UIButton> { get }
    var disposeBag: DisposeBag { get }
}

final class ListingDeckViewControllerBinder {

    weak var listingDeckViewController: ListingDeckViewControllerBinderType? = nil
    fileprivate(set) var disposeBag: DisposeBag?

    func bind(withViewModel viewModel: ListingDeckViewModelType, listingDeckView: ListingDeckViewType) {
        guard let viewController = listingDeckViewController else { return }
        let currentDB = DisposeBag()

        bindKeyboardChanges(withViewController: viewController, viewModel: viewModel,
                            listingDeckView: listingDeckView, disposeBag: currentDB)
        bindCollectionView(withViewController: viewController, viewModel: viewModel,
                           listingDeckView: listingDeckView, disposeBag: currentDB)
        bindContentOffset(withViewController: viewController, viewModel: viewModel,
                          listingDeckView: listingDeckView, disposeBag: currentDB)
        bindChat(withViewController: viewController, viewModel: viewModel,
                 listingDeckView: listingDeckView, disposeBag: currentDB)
        bindActions(withViewModel: viewModel, listingDeckView: listingDeckView, disposeBag: currentDB)
        bindBumpUp(withViewController: viewController, viewModel: viewModel,
                   listingDeckView: listingDeckView, disposeBag: currentDB)

        disposeBag = currentDB
    }

    func bind(cell: ListingDeckViewControllerBinderCellType) {
        guard let viewController = listingDeckViewController else { return }
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
    }

    private func bindActionButtonTap(withActions actionButtons: [UIAction],
                                     listingDeckView: ListingDeckViewType?,
                                     disposeBag: DisposeBag) {
        guard let actionButton = actionButtons.first else { return }
        listingDeckView?.rxActionButton.tap.bind {
            actionButton.action()
        }.disposed(by: disposeBag)
    }

    private func bindBumpUp(withViewController viewController: ListingDeckViewControllerBinderType,
                            viewModel: ListingDeckViewModelType, listingDeckView: ListingDeckViewType,
                            disposeBag: DisposeBag) {
        viewModel.rxBumpUpBannerInfo.bind { [weak viewController] bumpInfo in
            guard let bumpUp = bumpInfo else { return }
            viewController?.showBumpUpBanner(bumpInfo: bumpUp)
        }.disposed(by: disposeBag)
    }

    private func bindKeyboardChanges(withViewController viewController: ListingDeckViewControllerBinderType,
                                     viewModel: ListingDeckViewModelType, listingDeckView: ListingDeckViewType,
                                     disposeBag: DisposeBag) {
        viewController.keyboardChanges.bind { [weak viewController] change in
            viewController?.updateWith(keyboardChange: change)
        }.disposed(by: disposeBag)
    }

    private func bindCollectionView(withViewController viewController: ListingDeckViewControllerBinderType,
                                    viewModel: ListingDeckViewModelType, listingDeckView: ListingDeckViewType,
                                    disposeBag: DisposeBag) {
        viewModel.rxObjectChanges.observeOn(MainScheduler.instance).bind { [weak listingDeckView] change in
            listingDeckView?.collectionView.handleCollectionChange(change)
        }.disposed(by: disposeBag)

        listingDeckView.collectionView.rx.didEndDecelerating.bind { [weak viewController] in
            viewController?.blockSideInteractions()
            viewController?.setupPageCurrentCell()
        }.disposed(by: disposeBag)

        listingDeckView.collectionView.rx.willDisplayCell.bind { [weak viewController] (cell, indexPath) in
            viewController?.updateSideCells()
        }.disposed(by: disposeBag)
    }

    private func bindContentOffset(withViewController viewController: ListingDeckViewControllerBinderType,
                                   viewModel: ListingDeckViewModelType, listingDeckView: ListingDeckViewType,
                                   disposeBag: DisposeBag) {
        let pageSignal: Observable<Int> = viewController.rxContentOffset.map { _ in return listingDeckView.currentPage }
        pageSignal.skip(1).distinctUntilChanged().bind { [weak viewModel] page in
            // TODO: Tracking 3109
            viewModel?.moveToProductAtIndex(page, movement: .swipeRight)
        }.disposed(by: disposeBag)
    }

    private func bindChat(withViewController viewController: ListingDeckViewControllerBinderType,
                          viewModel: ListingDeckViewModelType, listingDeckView: ListingDeckViewType,
                          disposeBag: DisposeBag) {
        viewController.rxContentOffset.skip(1).bind { [weak viewModel, weak viewController] _ in
            viewModel?.userHasScrolled = true
            viewController?.closeBumpUpBanner()
        }.disposed(by: disposeBag)

        let contentOffsetAlphaSignal: Observable<CGFloat> = viewController.rxContentOffset
            .map { [weak listingDeckView] point in
                let pageOffset = listingDeckView?.pageOffset(givenOffset: point.x).truncatingRemainder(dividingBy: 1.0) ?? 0.5
                guard pageOffset >= 0.5 else {
                    return 2*pageOffset
                }
                return 2*(1 - pageOffset)   
        }.distinctUntilChanged()

        let areActionsEnabled = viewModel.rxActionButtons.map { $0.count > 0 }
        let chatEnabled: Observable<Bool> = viewModel.rxIsChatEnabled.distinctUntilChanged()
        Observable.combineLatest(contentOffsetAlphaSignal,
                                 chatEnabled,
                                 viewModel.rxIsMine.distinctUntilChanged(),
                                 areActionsEnabled.distinctUntilChanged()) { ($0, $1, $2, $3) }
            .observeOn(MainScheduler.asyncInstance)
            .bind { [weak viewController] (offsetAlpha, isChatEnabled, isMine, actionsEnabled) in
                viewController?.updateViewWith(alpha: offsetAlpha, chatEnabled: isChatEnabled,
                                               isMine: isMine, actionsEnabled: actionsEnabled)
        }.disposed(by: disposeBag)
    }
}
