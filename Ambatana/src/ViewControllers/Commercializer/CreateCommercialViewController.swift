//
//  CreateCommercialViewController.swift
//  LetGo
//
//  Created by Isaac Roldán Armengol on 4/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class CreateCommercialViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
   
    private var viewModel : CreateCommercialViewModel!
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = view.center
        activityIndicator.autoresizingMask = [.FlexibleLeftMargin, .FlexibleTopMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        view.addSubview(activityIndicator)
        
        let themeCell = UINib(nibName: "CreateCommercialProductCell", bundle: nil)
        collectionView.registerNib(themeCell, forCellWithReuseIdentifier: "CreateCommercialProductCell")
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.alwaysBounceVertical = true
        
        setLetGoNavigationBarStyle(LGLocalizedString.commercializerIntroTitleLabel)
    }
    
    convenience init(viewModel: CreateCommercialViewModel) {
        self.init(viewModel: viewModel, nibName: "CreateCommercialViewController")
        self.viewModel = viewModel
        self.viewModel.delegate = self
    }
    
    private func showActivityIndicator(show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}


// MARK: > CreateCommercialViewModelDelegate

extension CreateCommercialViewController: CreateCommercialViewModelDelegate {
    
    func vmWillStartDownloadingProducts() {
        showActivityIndicator(true)
    }
    
    func vmDidFailProductsDownload() {
        showActivityIndicator(false)
    }
    
    func vmDidFinishDownloadingProducts() {
        showActivityIndicator(false)
        collectionView.reloadData()
    }
}


// MARK: > UICollectionView Delegate & DataSource

extension CreateCommercialViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            
            let collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("CreateCommercialProductCell",
                                                                                       forIndexPath: indexPath)
            guard let cell = collectionCell as? CreateCommercialProductCell else { return UICollectionViewCell() }
            
            if let urlString = viewModel.products[indexPath.row].thumbnailURL, let url = NSURL(string: urlString) {
                cell.imageView.sd_setImageWithURL(url)
            }
            return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // OPEN COMMERCIALIZER
    }
}


// MARK: > UICollectionViewDelegateFlowLayout

extension CreateCommercialViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width-30)/2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}