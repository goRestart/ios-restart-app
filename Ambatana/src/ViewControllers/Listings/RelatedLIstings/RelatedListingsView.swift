//
//  RelatedListingsView.swift
//  LetGo
//
//  Created by Eli Kohen on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import RxCocoa


protocol RelatedListingsViewDelegate: class {
    func relatedListingsView(_ view: RelatedListingsView, showListing listing: Listing, atIndex index: Int,
                             listingListModels: [ListingCellModel], requester: ListingListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?)
}


class RelatedListingsView: UIView {

    fileprivate static let defaultListingsDiameter: CGFloat = 100
    fileprivate static let elementsMargin: CGFloat = 10
    fileprivate static let itemsSpacing: CGFloat = 5

    let listingId = Variable<String?>(nil)
    let hasListings = Variable<Bool>(false)

    weak var delegate: RelatedListingsViewDelegate?

    fileprivate let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate let listingsDiameter: CGFloat

    fileprivate var requester: ListingListRequester?
    fileprivate var objects: [ListingCellModel] = [] {
        didSet {
            hasListings.value = !objects.isEmpty
        }
    }
    fileprivate let drawerManager = GridDrawerManager(myUserRepository: Core.myUserRepository)

    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience override init(frame: CGRect) {
        self.init(listingsDiameter: RelatedListingsView.defaultListingsDiameter, frame: frame)
    }

    init(listingsDiameter: CGFloat, frame: CGRect) {
        self.listingsDiameter = listingsDiameter
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        self.listingsDiameter = RelatedListingsView.defaultListingsDiameter
        super.init(coder: aDecoder)
        setup()
    }


    // MARK: - Private

    private func setup() {
        backgroundColor = .clear

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        setupCollection()

        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        let views = ["collectionView": collectionView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil,
            views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil,
            views: views))
    }

    private func setupRx() {
        listingId.asObservable().bindNext{ [weak self] listingId in
             guard let listingId = listingId else {
                self?.clear()
                return
            }
            self?.loadListings(listingId)
        }.addDisposableTo(disposeBag)
        hasListings.asObservable().map { !$0 }.bindTo(self.rx.isHidden).addDisposableTo(disposeBag)
    }
}


// MARK: - UICollectionView

extension RelatedListingsView: UICollectionViewDelegate, UICollectionViewDataSource {

    fileprivate func setupCollection() {
        drawerManager.cellStyle = .relatedListings
        drawerManager.registerCell(inCollectionView: collectionView)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: RelatedListingsView.elementsMargin, bottom: 0,
                                                   right: RelatedListingsView.elementsMargin)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            layout.itemSize = CGSize(width: listingsDiameter, height: listingsDiameter)
            layout.minimumInteritemSpacing = RelatedListingsView.itemsSpacing
        }
    }

    fileprivate func clear() {
        objects = []
        collectionView.reloadData()
    }

    private func itemAtIndex(_ index: Int) -> ListingCellModel? {
        guard 0..<objects.count ~= index else { return nil }
        return objects[index]
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let item = itemAtIndex(indexPath.row) else { return UICollectionViewCell() }
            let cell = drawerManager.cell(item, collectionView: collectionView, atIndexPath: indexPath)
        drawerManager.draw(item, inCell: cell, delegate: nil, shouldShowPrice: false)
            cell.tag = (indexPath as NSIndexPath).hash
            (cell as? ListingCell)?.isRelatedEnabled = false
            return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = itemAtIndex(indexPath.row) else { return }
        switch item {
        case let .listingCell(listing):
            let cell = collectionView.cellForItem(at: indexPath) as? ListingCell
            let thumbnailImage = cell?.thumbnailImageView.image

            var originFrame: CGRect? = nil
            if let cellFrame = cell?.frame {
                originFrame = superview?.convert(cellFrame, from: collectionView)
            }
            guard let requester = requester else { return }
            delegate?.relatedListingsView(self, showListing: listing, atIndex: indexPath.row,
                                          listingListModels: objects, requester: requester,
                                          thumbnailImage: thumbnailImage, originFrame: originFrame)
        case .collectionCell, .emptyCell:
            // No banners or collections here
            break
        }
    }
}


// MARK: - Data handling

fileprivate extension RelatedListingsView {

    func loadListings(_ listingId: String) {
        clear()
        requester = RelatedListingListRequester(listingType: .product, listingId: listingId, itemsPerPage: Constants.numListingsPerPageDefault)
        requester?.retrieveFirstPage { [weak self] result in
            guard let listings = result.listingsResult.value else { return }
            if !listings.isEmpty {
                let listingCellModels = listings.map(ListingCellModel.init)
                self?.objects = listingCellModels
            } else {
                self?.objects = []
            }
            self?.collectionView.reloadData()
        }
    }
}
