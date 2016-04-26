//
//  ProductCarouselViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

class ProductCarouselViewController: BaseViewController {
    
    var collectionView: UICollectionView
    var viewModel: ProductCarouselViewModel
    
    // To restore navbar
    private var navBarBgImage: UIImage?
    private var navBarShadowImage: UIImage?
    
    
    // MARK: - Init
    
    init(viewModel: ProductCarouselViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        super.init(viewModel: viewModel, nibName: nil)
        layout.itemSize = view.bounds.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupNavigationBar()
        setupUI()
        navBarBgImage = navigationController?.navigationBar.backgroundImageForBarMetrics(.Default)
        navBarShadowImage = navigationController?.navigationBar.shadowImage
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(navBarBgImage, forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = navBarShadowImage
    }
    
    func addSubviews() {
        view.addSubview(collectionView)
    }
    
    func setupUI() {
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        collectionView.dataSource = self
        collectionView.registerClass(ProductCarouselCell.self, forCellWithReuseIdentifier: ProductCarouselCell.identifier)
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
    func didTapOnCarouselCell(cell: UICollectionViewCell) {
        let indexPath = collectionView.indexPathForCell(cell)!
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
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProductCarouselCell.identifier,
                                                                             forIndexPath: indexPath)
            guard let carouselCell = cell as? ProductCarouselCell else { return UICollectionViewCell() }
            guard let product = viewModel.productAtIndex(indexPath.row) else { return carouselCell }
            carouselCell.backgroundColor = StyleHelper.productCellImageBgColor
            carouselCell.configureCellWithProduct(product)
            carouselCell.delegate = self
            prefetchImages(indexPath.row)
            prefetchNeighborsImages(indexPath.row)
            return carouselCell
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
        ImageDownloader.sharedInstance.downloadImagesWithURLs(imagesToPrefetch)
    }
    
    func prefetchImages(index: Int) {
        guard let product = viewModel.productAtIndex(index) else { return }
        let urls = product.images.flatMap({$0.fileURL})
        ImageDownloader.sharedInstance.downloadImagesWithURLs(urls)
    }
}
