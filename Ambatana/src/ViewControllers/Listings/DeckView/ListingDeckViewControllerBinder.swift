import Foundation
import LGCoreKit
import RxCocoa
import RxSwift
import GoogleMobileAds
import LGComponents

final class ListingDeckViewControllerBinder {
    weak var listingDeckViewController: ListingDeckViewController? = nil
    fileprivate(set) var disposeBag: DisposeBag?

    func bind(withViewModel viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView) {
        guard let viewController = listingDeckViewController else { return }
        let currentDB = DisposeBag()
        disposeBag = currentDB

        bindCollectionView(withViewController: viewController, viewModel: viewModel,
                           listingDeckView: listingDeckView, disposeBag: currentDB)
        bindDeckMovement(withViewController: viewController, viewModel: viewModel,
                          listingDeckView: listingDeckView, disposeBag: currentDB)
        bindChat(withViewController: viewController, viewModel: viewModel,
                 listingDeckView: listingDeckView, disposeBag: currentDB)
        bindActions(withViewModel: viewModel, listingDeckView: listingDeckView, disposeBag: currentDB)
        bindActionButtonTap(withViewModel: viewModel, listingDeckView: listingDeckView, disposeBag: currentDB)
        bindBumpUps(withViewModel: viewModel, viewController: viewController, listingDeckView: listingDeckView, disposeBag: currentDB)
    }

    private func bindActions(withViewModel viewModel: ListingDeckViewModel,
                             listingDeckView: ListingDeckView,
                             disposeBag: DisposeBag) {
        guard let deckVC = listingDeckViewController else { return }
        viewModel.rx.actionButtons.map { return $0.first }
            .bind(to: deckVC.rx.action)
            .disposed(by: disposeBag)

        listingDeckView.rx.statusControlEvent
            .asDriver()
            .drive(onNext: { [weak self] _ in
            self?.listingDeckViewController?.didTapStatus()
        }).disposed(by: disposeBag)
    }

    private func bindActionButtonTap(withViewModel viewModel: ListingDeckViewModel,
                                     listingDeckView: ListingDeckView?,
                                     disposeBag: DisposeBag) {
        listingDeckView?.rx.actionButton
            .tap
            .bind { [weak viewModel] in
            viewModel?.didTapActionButton()
        }.disposed(by: disposeBag)
    }

    private func bindBumpUps(withViewModel viewModel: ListingDeckViewModel,
                             viewController: ListingDeckViewController,
                             listingDeckView: ListingDeckView,
                             disposeBag: DisposeBag) {
        let didEndDecelerating = listingDeckView.rx.collectionView.didEndDecelerating
        let bumpUp = viewModel.bumpUpBannerInfo.asObservable().share()
        let willBeginDragging = listingDeckView.rx.collectionView.willBeginDragging

        bumpUp
            .takeUntil(willBeginDragging.asObservable())
            .bind(to: viewController.rx.bumpUp)
            .disposed(by: disposeBag)
        Observable
            .combineLatest(didEndDecelerating, bumpUp) { ($0, $1) }.map { $0.1 }
            .bind(to: viewController.rx.bumpUp)
            .disposed(by: disposeBag)
    }

    private func bindCollectionView(withViewController viewController: ListingDeckViewController,
                                    viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView,
                                    disposeBag: DisposeBag) {
        viewModel.rx.objectChanges
            .observeOn(MainScheduler.instance)
            .bind { [weak listingDeckView] change in
            listingDeckView?.handleCollectionChange(change, completion: nil)
        }.disposed(by: disposeBag)

        let willBeginDragging = listingDeckView.rx.collectionView.willBeginDragging
        let didEndDecelerating = listingDeckView.rx.collectionView.didEndDecelerating

        willBeginDragging
            .asDriver().drive(onNext: { [weak viewController] _ in
                viewController?.willBeginDragging()
        }).disposed(by: disposeBag)

        didEndDecelerating.asDriver()
            .drive(onNext: { [weak viewController] _ in
            viewController?.didEndDecelerating()
        }).disposed(by: disposeBag)

        listingDeckView.rx.collectionView
            .willDisplayCell
            .bind { [weak viewController] (cell, indexPath) in
            viewController?.willDisplayCell(cell, atIndexPath: indexPath)
        }.disposed(by: disposeBag)
    }

    private func bindDeckMovement(withViewController viewController: ListingDeckViewController,
                                   viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView,
                                   disposeBag: DisposeBag) {
        let pageSignal: Observable<Int> = viewController.rx.contentOffset.map { [weak listingDeckView] _ in
            return listingDeckView?.currentPage ?? 0
        }
        pageSignal.skip(1).distinctUntilChanged().bind { [weak viewModel, weak viewController] page in
            viewController?.didMoveToItemAtIndex(page)
            if let currentIndex = viewModel?.currentIndex, currentIndex < page {
                viewModel?.moveToListingAtIndex(page, movement: .swipeRight)
                viewController?.presentInterstitialAtIndex(page)
            } else if let currentIndex = viewModel?.currentIndex, currentIndex > page {
                viewModel?.moveToListingAtIndex(page, movement: .swipeLeft)
            }
        }.disposed(by: disposeBag)
    }

    private func bindChat(withViewController viewController: ListingDeckViewController,
                          viewModel: ListingDeckViewModel, listingDeckView: ListingDeckView,
                          disposeBag: DisposeBag) {
        let offset: Observable<CGPoint> = viewController.rx.contentOffset.share()

        offset.skip(1)
            .bind { [weak viewModel] _ in
            viewModel?.userHasScrolled = true
        }.disposed(by: disposeBag)

        let normalized: Observable<CGFloat> = offset.map { [weak listingDeckView] (point) -> CGFloat in
            let pageOffset = listingDeckView?
                .normalizedPageOffset(givenOffset: point.x)
                .truncatingRemainder(dividingBy: 1.0) ?? 0.5
            guard pageOffset >= 0.5 else { return 2*pageOffset }
            return 2*(1 - pageOffset)
        }.distinctUntilChanged()

        Observable.combineLatest(normalized, viewModel.rx.isMine) { ($0, $1) }.map { (alpha, isMine) in
            guard !isMine else { return 0 }
            return alpha
        }.bind(to: viewController.rx.chatAlpha).disposed(by: disposeBag)

        Observable.combineLatest(normalized, viewModel.rx.isMine) { ($0, $1) }.map { (alpha, isMine) in
            guard isMine else { return 0 }
            return alpha
        }.bind(to: viewController.rx.actionsAlpha).disposed(by: disposeBag)
    }
}
