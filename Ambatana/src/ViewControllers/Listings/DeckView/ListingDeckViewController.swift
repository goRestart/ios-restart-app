//
//  ListingDeckViewController.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit

final class ListingDeckViewController: BaseViewController, UICollectionViewDataSource {

    struct Identifiers {
        static let cardView = "ListingCardView"
    }
    let listingDeckView = ListingDeckView()

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
        listingDeckView.collectionView.dataSource = self
        listingDeckView.collectionView.reloadData()
        listingDeckView.collectionView.register(ListingCardView.self, forCellWithReuseIdentifier: Identifiers.cardView)
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.cardView, for: indexPath) as? ListingCardView {
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

    }

    @objc private func didTapMoreInfo() {

    }

}
