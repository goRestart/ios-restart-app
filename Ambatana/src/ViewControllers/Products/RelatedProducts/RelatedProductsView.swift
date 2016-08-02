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

    private static let defaultProductsDiameter: CGFloat = 100
    private static let elementsMargin: CGFloat = 15
    private static let itemsSpacing: CGFloat = 5

    let title = Variable<String>("")
    let productId = Variable<String?>(nil)

    weak var delegate: RelatedProductsViewDelegate?

    private var topConstraint: NSLayoutConstraint?
    private let infoLabel = UILabel()
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let productsDiameter: CGFloat

    private var objects: [ProductCellModel] = []
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


    // MARK: - Public

    func setupOnTopOfView(sibling: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let parentView = sibling.superview else { return }
        parentView.addSubview(self)
        let top = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy:
            NSLayoutRelation.Equal, toItem: sibling, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal,
                                      toItem: sibling, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal,
                                       toItem: sibling, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        parentView.addConstraints([top,left,right])
        topConstraint = top
    }


    // MARK: - Private

    private func setup() {
        backgroundColor = UIColor.whiteColor()
        layer.borderWidth = LGUIKitConstants.onePixelSize
        layer.borderColor = UIColor.lineGray.CGColor

        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = UIColor.grayDark
        infoLabel.font = UIFont.sectionTitleFont
        addSubview(infoLabel)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        setupCollection()

        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        let views = ["infoLabel": infoLabel, "collectionView": collectionView]
        let metrics = ["margin": RelatedProductsView.elementsMargin, "collectionHeight": productsDiameter]
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
}


// MARK: - UICollectionView

extension RelatedProductsView: UICollectionViewDelegate, UICollectionViewDataSource {

    private func setupCollection() {
        drawerManager.cellStyle = .Small
        drawerManager.registerCell(inCollectionView: collectionView)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: RelatedProductsView.elementsMargin, bottom: 0,
                                                   right: RelatedProductsView.elementsMargin)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
            layout.itemSize = CGSize(width: productsDiameter, height: productsDiameter)
            layout.minimumInteritemSpacing = RelatedProductsView.itemsSpacing
        }
    }

    private func itemAtIndex(index: Int) -> ProductCellModel? {
        guard 0..<objects.count ~= index else { return nil }
        return objects[index]
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
         -> UICollectionViewCell {
            guard let item = itemAtIndex(indexPath.row) else { return UICollectionViewCell() }
            let cell = drawerManager.cell(item, collectionView: collectionView, atIndexPath: indexPath)
            drawerManager.draw(item, inCell: cell)
            cell.tag = indexPath.hash
            return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let item = itemAtIndex(indexPath.row) else { return }
        switch item {
        case let .ProductCell(product):
            delegate?.relatedProductsView(self, didSelectProduct: product)
        case .BannerCell:
            // No banners here
            break
        }
    }
}


// MARK: - Data handling

private extension RelatedProductsView {

    func loadProducts(productId: String) {
        let requester = RelatedProductListRequester(productId: productId)
        requester.retrieveFirstPage { [weak self] result in
            guard let products = result.value where !products.isEmpty  else { return }
            let productCellModels = products.map(ProductCellModel.init)
            self?.objects = productCellModels
            self?.collectionView.reloadData()
            self?.animateToVisible()
        }
    }

    func animateToVisible() {
        topConstraint?.constant = -height
        UIView.animateWithDuration(0.3) { [weak self] in
            self?.superview?.layoutIfNeeded()
        }
    }
}
