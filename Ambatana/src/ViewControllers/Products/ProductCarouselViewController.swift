//
//  ProductCarouselViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import SDWebImage

class ProductCarouselViewController: BaseViewController {
    
    var collectionView: UICollectionView
    var viewModel: ProductCarouselViewModel
    
    // MARK: - Init
    
    init(viewModel: ProductCarouselViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        super.init(viewModel: viewModel, nibName: nil)
        layout.itemSize = view.bounds.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        addSubviews()
        setupNavigationBar()
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func addSubviews() {
        view.addSubview(collectionView)
    }
    
    func setupUI() {
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(ProductCarouselCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = UIColor.greenColor()
        collectionView.alwaysBounceHorizontal = true
        collectionView.allowsSelection = true
        automaticallyAdjustsScrollViewInsets = false
    }
    
    private func setupNavigationBar() {
        let backIcon = UIImage(named: "ic_close")
        setLetGoNavigationBarStyle("", backIcon: backIcon)
    }
}


// MARK: > ProductCarousel Cell Delegate

extension ProductCarouselViewController: ProductCarouselCellDelegate {
    func didTapOnCarouselCell() {
        
    }
}


// MARK: > CollectionView Delegate


extension ProductCarouselViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let newIndexRow = indexPath.row + 1
        if newIndexRow < collectionView.numberOfItemsInSection(0) {
            let nextIndexPath = NSIndexPath(forItem: newIndexRow, inSection: 0)
            collectionView.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: .Right, animated: true)
        } else {
            collectionView.showRubberBandEffect(.Right)
        }
    }
}


// MARK: > CollectionView Data Source

extension ProductCarouselViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as?
            ProductCarouselCell else { return UICollectionViewCell() }
        guard let product = viewModel.productAtIndex(indexPath.row) else { return UICollectionViewCell() }
        cell.backgroundColor = StyleHelper.productCellImageBgColor
        cell.configureCellWithProduct(product)
        prefetchImages(indexPath.row)
        prefetchNeighborsImages(indexPath.row)
        return cell
    }
}


// MARK: > Image PreCaching

extension ProductCarouselViewController {
    func prefetchNeighborsImages(index: Int) {
        var imagesToPrefetch: [NSURL] = []
        if let prevProduct = viewModel.productAtIndex(index - 1), let imageUrl = prevProduct.images.first?.fileURL {
            imagesToPrefetch.append(imageUrl)
        }
        if let nextProduct = viewModel.productAtIndex(index + 1), let imageUrl = nextProduct.images.first?.fileURL {
            imagesToPrefetch.append(imageUrl)
        }
        SDWebImagePrefetcher.sharedImagePrefetcher().prefetchURLs(imagesToPrefetch)
    }
    
    func prefetchImages(index: Int) {
        guard let product = viewModel.productAtIndex(index) else { return }
        let urls = product.images.flatMap({$0.fileURL})
        SDWebImagePrefetcher.sharedImagePrefetcher().prefetchURLs(urls)
    }
}
