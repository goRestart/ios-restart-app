//
//  RelatedProductsView.swift
//  LetGo
//
//  Created by Eli Kohen on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import RxCocoa


protocol RelatedProductsViewDelegate: class {
    func relatedProductsView(view: RelatedProductsView, didSelectProduct: Product)
}


class RelatedProductsView: UIView {

    let title = Variable<String>("")
    let productId = Variable<String?>(nil)
    let productsCount = PublishSubject<Int>()

    weak var delegate: RelatedProductsViewDelegate?

    private let infoLabel = UILabel()
    private let collectionView = UICollectionView()

    private var relatedProducts: [Product] = [] {
        didSet {
            productsCount.onNext(relatedProducts.count)
        }
    }

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    // MARK: - Private

    private func setup() {
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(infoLabel)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        setupCollection()

        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        let views = ["infoLabel": infoLabel, "collectionView": collectionView]
        let metrics = ["margin": 15, "collectionHeight": 100]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[infoLabel]-margin-|", options: [],
            metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: [], metrics: nil,
            views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-margin-[infoLabel]-margin-[collectionView(collectionHeight)]-margin-|",
            options: [], metrics: metrics, views: views))
    }

    private func setupRx() {
        title.asObservable().bindTo(infoLabel.rx_text).addDisposableTo(disposeBag)
        productId.asObservable().bindNext{ [weak self] productId in
             guard let productId = productId else { return }
            self?.loadProducts(productId)
        }.addDisposableTo(disposeBag)
    }

    private func loadProducts(productId: String) {
        let requester = RelatedProductListRequester(productId: productId)
        requester.retrieveFirstPage { [weak self] result in
            guard let products = result.value where !products.isEmpty  else { return }
            self?.relatedProducts = products
            self?.collectionView.reloadData()
        }
    }
}


// MARK: - UICollectionView

extension RelatedProductsView: UICollectionViewDelegate, UICollectionViewDataSource {

    private func setupCollection() {
        collectionView.registerClass(RelatedProductCell.self, forCellWithReuseIdentifier: RelatedProductCell.reusableID)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func getProduct(index: Int) -> Product? {
        guard 0..<relatedProducts.count ~= index else { return nil }
        return relatedProducts[index]
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return relatedProducts.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
         -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(RelatedProductCell.reusableID,
                                forIndexPath: indexPath) as? RelatedProductCell else { return UICollectionViewCell() }
            guard let product = getProduct(indexPath.row) else { return UICollectionViewCell() }
            cell.setupWithImageUrl(product.thumbnail?.fileURL)
            return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let product = getProduct(indexPath.row) else { return }
        delegate?.relatedProductsView(self, didSelectProduct: product)
    }
}
