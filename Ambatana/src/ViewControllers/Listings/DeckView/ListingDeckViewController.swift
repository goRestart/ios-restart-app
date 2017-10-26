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

final class ListingDeckViewController: BaseViewController, UICollectionViewDataSource {

    struct Identifiers {
        static let cardView = "ListingCardView"
    }
    let listingDeckView = ListingDeckView()

    fileprivate let viewModel: ListingDeckViewModel
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: ListingDeckViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        self.view = listingDeckView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
    }

    // MARK: CollectionView

    private func setupCollectionView() {
        func setupCollectionRx() {
            viewModel.objectChanges.observeOn(MainScheduler.instance).bindNext { [weak self] change in
                guard let strongSelf = self else { return }
                strongSelf.listingDeckView.collectionView.reloadData()
                }.addDisposableTo(disposeBag)
        }

        listingDeckView.collectionView.dataSource = self
        listingDeckView.collectionView.reloadData()
        listingDeckView.collectionView.register(ListingCardView.self, forCellWithReuseIdentifier: Identifiers.cardView)

        setupCollectionRx()
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

    // MARK: NavBar

    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        edgesForExtendedLayout = []

        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_more_options"), style: .plain, target: self, action: #selector(didTapMoreInfo))
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_red"), style: .plain, target: self, action: #selector(didTapClose))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.leftBarButtonItem  = leftButton
    }

    @objc private func didTapClose() {
//            closeBumpUpBanner()
        viewModel.close()
    }

    @objc private func didTapMoreInfo() {
        
    }
    
}
