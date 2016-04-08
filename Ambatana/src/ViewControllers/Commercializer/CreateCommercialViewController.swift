//
//  CreateCommercialViewController.swift
//  LetGo
//
//  Created by Isaac Roldán Armengol on 4/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

class CreateCommercialViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emptyView: LGEmptyView!
    
    private let viewModel : CreateCommercialViewModel
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: CreateCommercialViewModel) {
        self.init(viewModel: viewModel, nibName: "CreateCommercialViewController")
    }
    
    required init(viewModel: CreateCommercialViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        collectionView.contentInset = UIEdgeInsetsZero
        collectionView.alwaysBounceVertical = true
        automaticallyAdjustsScrollViewInsets = false
        
        titleLabel.text = LGLocalizedString.commercializerSelectFromSettingsTitle
        titleLabel.font = StyleHelper.commercialFromSettingsTitleFont
        titleLabel.textColor = StyleHelper.commercialFromSettingsTitleColor
        
        setLetGoNavigationBarStyle(LGLocalizedString.commercializerIntroTitleLabel)
        
        setupStatusBindings()
    }
    
    
    // MARK: - Bindings
    
    func setupStatusBindings() {
        viewModel.status.asObservable().subscribeNext { [weak self] status in
            switch status {
            case .None:
                self?.showActivityIndicator(false)
                self?.hideAll()
            case .Loading:
                self?.showActivityIndicator(true)
                self?.hideAll()
            case .Data:
                self?.showActivityIndicator(false)
                self?.collectionView.reloadData()
                self?.hideEmptyView()
            case .Empty(let vm):
                self?.showActivityIndicator(false)
                self?.emptyView.setupWithModel(vm)
                self?.showEmptyView()
            case .Error(let vm):
                self?.showActivityIndicator(false)
                self?.emptyView.setupWithModel(vm)
                self?.showEmptyView()
            }
            }.addDisposableTo(disposeBag)
    }
    
    func showEmptyView() {
        emptyView.hidden = false
        collectionView.hidden = true
        titleLabel.hidden = true
    }
    
    func hideEmptyView() {
        emptyView.hidden = true
        collectionView.hidden = false
        titleLabel.hidden = false
    }
    
    func hideAll() {
        emptyView.hidden = true
        collectionView.hidden = true
        titleLabel.hidden = true
    }
    
    private func showActivityIndicator(show: Bool) {
        show ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}


// MARK: > CreateCommercialViewModelDelegate

extension CreateCommercialViewController: CreateCommercialViewModelDelegate {
    func vmOpenSell() {
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        tabBarController.sellButtonPressed()
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
            
            if let urlString = viewModel.thumbnailAt(indexPath.row), let url = NSURL(string: urlString) {
                cell.imageView.sd_setImageWithURL(url)
            }
            return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let productId = viewModel.productIdAt(indexPath.row) else { return }
        guard let templates = viewModel.commercializerTemplates(indexPath.row) else { return }
        guard let vm = PromoteProductViewModel(productId: productId, themes: templates, commercializers: nil,
                                               promotionSource: .Settings) else { return }
        let vc = PromoteProductViewController(viewModel: vm)
        vc.delegate = self
        presentViewController(vc, animated: true, completion: nil)
    }
}


// MARK: > PromoteProductViewControllerDelegate

extension CreateCommercialViewController: PromoteProductViewControllerDelegate {
    func promoteProductViewControllerDidFinishFromSource(promotionSource: PromotionSource) {
        popViewController(animated: true, completion: nil)
    }
    
    func promoteProductViewControllerDidCancelFromSource(promotionSource: PromotionSource) {
    }
}


// MARK: > UICollectionViewDelegateFlowLayout

extension CreateCommercialViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 13, bottom: 13, right: 13)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 13
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 13
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width-39)/2
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
