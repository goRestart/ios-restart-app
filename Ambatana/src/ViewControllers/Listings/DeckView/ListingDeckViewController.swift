//
//  ListingDeckViewController.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class ListingDeckViewController: KeyboardViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    struct Identifiers {
        static let cardView = "ListingCardView"
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    var contentOffset: Observable<CGFloat> { return  contentOffsetVar.asObservable() }
    private let contentOffsetVar = Variable<CGFloat>(0)
    fileprivate let listingDeckView = ListingDeckView()
    fileprivate let viewModel: ListingDeckViewModel
    fileprivate let binder = ListingDeckViewControllerBinder()

    fileprivate var transitioner: PhotoViewerTransitionAnimator?

    init(viewModel: ListingDeckViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        self.view = listingDeckView
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listingDeckView.updateTop(wintInset: topBarHeight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()

        setupCollectionView()
        setupDirectChat()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    // MARK: Rx

    private func setupRx() {
        binder.listingDeckViewController = self
        binder.bind(withViewModel: viewModel, listingDeckView: listingDeckView)
    }

    // MARK: CollectionView

    private func setupCollectionView() {
        listingDeckView.collectionView.dataSource = self
        listingDeckView.collectionView.delegate = self
        listingDeckView.collectionView.reloadData()
        listingDeckView.collectionView.register(ListingCardView.self, forCellWithReuseIdentifier: Identifiers.cardView)
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.objectCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.cardView, for: indexPath) as? ListingCardView {
            guard let listing = viewModel.listingCellModelAt(index: indexPath.row) else {
                return cell
            }
            cell.populateWith(listingViewModel: listing, imageDownloader: viewModel.imageDownloader)
            binder.bind(cell: cell)
            cell.delegate = self

            return cell
        }
        return UICollectionViewCell()
    }

    // ScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffsetVar.value = scrollView.contentOffset.x
    }

    // MARK: NavBar

    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear

        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_more_options"), style: .plain, target: self, action: #selector(didTapMoreInfo))
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_red"), style: .plain, target: self, action: #selector(didTapClose))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.leftBarButtonItem  = leftButton

        setNavigationBarRightButtons([])
    }

    func didTapShare() {
        viewModel.currentListingViewModel?.shareProduct()
    }

    func didTapCardAction() {
        viewModel.didTapCardAction()
    }

    @objc private func didTapClose() {
        closeBumpUpBanner()
        UIView.animate(withDuration: 0.3, animations: { 
            self.listingDeckView.resignFirstResponder()
        }) { (completion) in
            self.viewModel.close()
        }
    }

    @objc private func didTapMoreInfo() {

    }

    // MARK: DirectAnswersHorizontalViewDelegate

    private func setupDirectChat() {
        listingDeckView.setDirectAnswersHorizontalViewDelegate(self)
    }

    func updateViewWith(alpha: CGFloat) {
        let chatAlpha = viewModel.chatEnabled.value ? alpha : 0
        let actionsAlpha = viewModel.chatEnabled.value ? 0 : alpha

        listingDeckView.updatePrivateActionsWith(alpha: actionsAlpha)
        listingDeckView.updateChatWith(alpha: chatAlpha)
    }

    func showBumpUpBanner(bumpInfo: BumpUpInfo){
        guard !listingDeckView.isBumpUpVisible else {
            // banner is already visible, but info changes
            listingDeckView.updateBumpUp(withInfo: bumpInfo)
            return
        }

        viewModel.bumpUpBannerShown(type: bumpInfo.type)
        delay(1.0) { [weak self] in
            self?.listingDeckView.updateBumpUp(withInfo: bumpInfo)
            self?.listingDeckView.bumpUpBanner.setNeedsLayout()
            self?.listingDeckView.bumpUpBanner.layoutIfNeeded()

            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 6.0,
                           initialSpringVelocity: 3.0,
                           options: .layoutSubviews, animations: {
                            self?.listingDeckView.showBumpUp()
                            self?.listingDeckView.layoutIfNeeded()
            }, completion: nil)
        }
    }

    func closeBumpUpBanner() {
        listingDeckView.hideBumpUp()
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 6.0,
                       initialSpringVelocity: 3.0,
                       options: .layoutSubviews, animations: {
                        self.listingDeckView.layoutIfNeeded()
        }, completion: nil)
    }

}

extension ListingDeckViewController: UITableViewDataSource, UITableViewDelegate, DirectAnswersHorizontalViewDelegate {
    func setupDirectMessages() {
        let directChatTable = listingDeckView.directChatTable

        directChatTable.dataSource = self
        directChatTable.delegate = self
        ChatCellDrawerFactory.registerCells(directChatTable)
        directChatTable.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        directChatTable.rowHeight = UITableViewAutomaticDimension
        directChatTable.estimatedRowHeight = 140
        directChatTable.isCellHiddenBlock = { return $0.contentView.isHidden }
        // TODO: ABIOS-3107 https://ambatana.atlassian.net/browse/ABIOS-3107
        //        directChatTable.didSelectRowAtIndexPath = {  [weak self] _ in self?.viewModel.directMessagesItemPressed() }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.directChatMessages.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messages = viewModel.directChatMessages.value
        guard 0..<messages.count ~= indexPath.row else { return UITableViewCell() }
        let message = messages[indexPath.row]
        let drawer = ChatCellDrawerFactory.drawerForMessage(message, autoHide: true, disclosure: true)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)

        drawer.draw(cell, message: message)
        cell.transform = tableView.transform

        return cell
    }

    func directAnswersHorizontalViewDidSelect(answer: QuickAnswer, index: Int) {
        if let productVM = viewModel.currentListingViewModel, productVM.showKeyboardWhenQuickAnswer {
            listingDeckView.setChatText(answer.text)
        } else {
            // TODO: ABIOS-3107 https://ambatana.atlassian.net/browse/ABIOS-3107
            //            viewModel.send(quickAnswer: answer)
        }
        if let productVM = viewModel.currentListingViewModel, productVM.areQuickAnswersDynamic {
            // TODO: ABIOS-3107 https://ambatana.atlassian.net/browse/ABIOS-3107
            //            viewModel.moveQuickAnswerToTheEnd(index)
        }
    }

}

extension ListingDeckViewController: ListingDeckViewModelDelegate {
    func vmShowOptions(_ cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: nil)
    }

    func vmShowProductDetailOptions(_ cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: navigationItem.rightBarButtonItems?.first)
    }

    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        return (self, navigationItem.rightBarButtonItems?.first)
    }

    func vmResetBumpUpBannerCountdown() {
        listingDeckView.resetBumpUpCountdown()
    }
}

extension ListingDeckViewController: ListingCardDetailsViewDelegate, ListingCardViewDelegate, ListingCardDetailMapViewDelegate {
    func viewControllerToShowShareOptions() -> UIViewController { return self }

    func didTapOnMapSnapshot(_ snapshot: UIView) {
        let page = listingDeckView.currentPage
        guard let cell = listingDeckView.collectionView.cellForItem(at: IndexPath(row: page, section: 0))
            as? ListingCardView else { return }

        listingDeckView.collectionView.isScrollEnabled = false
        cell.showFullMap(fromRect: snapshot.frame)
    }

    func didTapOnPreview() {
        displayPhotoViewer()
    }

    func displayPhotoViewer() {
        let urls = viewModel.currentListingViewModel?.productImageURLs.value ?? []
        let photoVM = PhotoViewerViewModel(with: urls)
        let photoViewer = PhotoViewerViewController(viewModel: photoVM)
        photoViewer.transitioningDelegate = self

        self.present(photoViewer, animated: true, completion: nil)
    }

    func didTapMapView() {
        let page = listingDeckView.currentPage
        guard let cell = listingDeckView.collectionView.cellForItem(at: IndexPath(row: page, section: 0))
            as? ListingCardView else { return }
        listingDeckView.collectionView.isScrollEnabled = true
        cell.hideFullMap()
    }

    func didTapOnStatusView() {
        viewModel.didTapStatusView()
    }
}

extension ListingDeckViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let current = listingDeckView.currentPage
        let cell = listingDeckView.collectionView.cellForItem(at: IndexPath(row: current, section: 0)) as! ListingCardView
        let frame = cell.convert(cell.previewImageViewFrame, to: listingDeckView)

        guard let url = viewModel.urlAtIndex(0),
            let cached = viewModel.imageDownloader.cachedImageForUrl(url) else { return nil }
        transitioner = PhotoViewerTransitionAnimator(image: cached, initialFrame: frame)
        return transitioner
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitioner
    }
}
