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

    let contentOffset = Variable<CGFloat>(0)
    let overlaysAlpha = Variable<CGFloat>(1)
    let indexSignal = Variable<Int>(0)

    let listingDeckView = ListingDeckView()
    fileprivate let viewModel: ListingDeckViewModel
    fileprivate let binder = ListingDeckViewControllerBinder()

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
        listingDeckView.collectionViewTop?.constant = topBarHeight
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
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
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
            let listing = viewModel.listingCellModelAt(index: indexPath.row)
            cell.populateWith(listing?.listing.objectId ?? "IDENTIFICADOR")
            return cell
        }
        return UICollectionViewCell()
    }

    // ScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset.value = scrollView.contentOffset.x

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

    @objc private func didTapBumpUp() {

    }

    @objc private func didTapClose() {
        //            closeBumpUpBanner()
        viewModel.close()
    }

    @objc private func didTapMoreInfo() {

    }

    // MARK: DirectAnswersHorizontalViewDelegate

    private func setupDirectChat() {
        listingDeckView.directAnswersView.delegate = self
    }

    func updateViewWith(alpha: CGFloat) {
        let chatAlpha = viewModel.chatEnabled.value ? alpha : 0
        let actionsAlpha = viewModel.chatEnabled.value ? 0 : alpha

        listingDeckView.updatePrivateActionsWith(alpha: actionsAlpha)
        listingDeckView.updateChatWith(alpha: chatAlpha)
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
        print("Selected direct answer")
        if let productVM = viewModel.currentListingViewModel, productVM.showKeyboardWhenQuickAnswer {
            //            chatTextView.setText(answer.text)
        } else {
            //            viewModel.send(quickAnswer: answer)
        }
        
        if let productVM = viewModel.currentListingViewModel, productVM.areQuickAnswersDynamic {
            //            viewModel.moveQuickAnswerToTheEnd(index)
        }
    }
    
}

