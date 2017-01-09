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
    func relatedProductsView(_ view: RelatedProductsView, showProduct product: Product, atIndex index: Int,
                             productListModels: [ProductCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?)
}


class RelatedProductsView: UIView {

    private static let defaultProductsDiameter: CGFloat = 100
    private static let elementsMargin: CGFloat = 10
    private static let itemsSpacing: CGFloat = 5

    let productId = Variable<String?>(nil)
    let hasProducts = Variable<Bool>(false)

    weak var delegate: RelatedProductsViewDelegate?

    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let productsDiameter: CGFloat

    private var requester: ProductListRequester?
    private var objects: [ProductCellModel] = [] {
        didSet {
            hasProducts.value = !objects.isEmpty
        }
    }
    private let drawerManager = GridDrawerManager()

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience override init(frame: CGRect) {
        self.init(productsDiameter: RelatedProductsView.defaultProductsDiameter, frame: frame)
    }

    init(productsDiameter: CGFloat, frame: CGRect) {
        self.productsDiameter = productsDiameter
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        self.productsDiameter = RelatedProductsView.defaultProductsDiameter
        super.init(coder: aDecoder)
        setup()
    }


    // MARK: - Private

    private func setup() {
        backgroundColor = UIColor.clear

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
        productId.asObservable().bindNext{ [weak self] productId in
             guard let productId = productId else {
                self?.clear()
                return
            }
            self?.loadProducts(productId)
        }.addDisposableTo(disposeBag)
        hasProducts.asObservable().map { !$0 }.bindTo(self.rx_hidden).addDisposableTo(disposeBag)
    }
}


// MARK: - UICollectionView

extension RelatedProductsView: UICollectionViewDelegate, UICollectionViewDataSource {

    private func setupCollection() {
        drawerManager.cellStyle = .small
        drawerManager.registerCell(inCollectionView: collectionView)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: RelatedProductsView.elementsMargin, bottom: 0,
                                                   right: RelatedProductsView.elementsMargin)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            layout.itemSize = CGSize(width: productsDiameter, height: productsDiameter)
            layout.minimumInteritemSpacing = RelatedProductsView.itemsSpacing
        }
    }

    private func clear() {
        objects = []
        collectionView.reloadData()
    }

    private func itemAtIndex(_ index: Int) -> ProductCellModel? {
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
            drawerManager.draw(item, inCell: cell)
            cell.tag = (indexPath as NSIndexPath).hash
            return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = itemAtIndex(indexPath.row) else { return }
        switch item {
        case let .ProductCell(product):
            let cell = collectionView.cellForItem(at: indexPath) as? ProductCell
            let thumbnailImage = cell?.thumbnailImageView.image

            var originFrame: CGRect? = nil
            if let cellFrame = cell?.frame {
                originFrame = superview?.convert(cellFrame, from: collectionView)
            }
            guard let requester = requester else { return }
            delegate?.relatedProductsView(self, showProduct: product, atIndex: indexPath.row,
                                          productListModels: objects, requester: requester,
                                          thumbnailImage: thumbnailImage, originFrame: originFrame)
        case .collectionCell, .emptyCell:
            // No banners or collections here
            break
        }
    }
}


// MARK: - Data handling

fileprivate extension RelatedProductsView {

    func loadProducts(_ productId: String) {
        clear()
        requester = RelatedProductListRequester(productId: productId, itemsPerPage: Constants.numProductsPerPageDefault)
        requester?.retrieveFirstPage { [weak self] result in
            if let products = result.value, !products.isEmpty {
                let productCellModels = products.map(ProductCellModel.init)
                self?.objects = productCellModels
            } else {
                self?.objects = []
            }
            self?.collectionView.reloadData()
        }
    }
}
