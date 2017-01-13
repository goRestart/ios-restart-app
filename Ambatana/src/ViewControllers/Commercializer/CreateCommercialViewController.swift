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
    
    fileprivate let viewModel : CreateCommercialViewModel
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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
        activityIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
        view.addSubview(activityIndicator)
        
        let themeCell = UINib(nibName: "CreateCommercialProductCell", bundle: nil)
        collectionView.register(themeCell, forCellWithReuseIdentifier: "CreateCommercialProductCell")
        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsets.zero
        collectionView.alwaysBounceVertical = true
        automaticallyAdjustsScrollViewInsets = false
        
        titleLabel.text = LGLocalizedString.commercializerSelectFromSettingsTitle
        titleLabel.font = UIFont.mediumBodyFont
        titleLabel.textColor = UIColor.blackText

        setNavBarTitle(LGLocalizedString.commercializerIntroTitleLabel)
        
        setupStatusBindings()
    }
    
    
    // MARK: - Bindings
    
    func setupStatusBindings() {
        viewModel.status.asObservable().subscribeNext { [weak self] status in
            switch status {
            case .none:
                self?.showActivityIndicator(false)
                self?.hideAll()
            case .loading:
                self?.showActivityIndicator(true)
                self?.hideAll()
            case .data:
                self?.showActivityIndicator(false)
                self?.collectionView.reloadData()
                self?.hideEmptyView()
            case .empty(let vm):
                self?.showActivityIndicator(false)
                self?.emptyView.setupWithModel(vm)
                self?.showEmptyView()
            case .error(let vm):
                self?.showActivityIndicator(false)
                self?.emptyView.setupWithModel(vm)
                self?.showEmptyView()
            }
            }.addDisposableTo(disposeBag)
    }
    
    func showEmptyView() {
        emptyView.isHidden = false
        collectionView.isHidden = true
        titleLabel.isHidden = true
    }
    
    func hideEmptyView() {
        emptyView.isHidden = true
        collectionView.isHidden = false
        titleLabel.isHidden = false
    }
    
    func hideAll() {
        emptyView.isHidden = true
        collectionView.isHidden = true
        titleLabel.isHidden = true
    }
    
    private func showActivityIndicator(_ show: Bool) {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            
            let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateCommercialProductCell",
                                                                                       for: indexPath)
            guard let cell = collectionCell as? CreateCommercialProductCell else { return UICollectionViewCell() }
            
            if let urlString = viewModel.thumbnailAt(indexPath.row), let url = URL(string: urlString) {
                cell.imageView.lg_setImageWithURL(url)
            }
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let productId = viewModel.productIdAt(indexPath.row) else { return }
        guard let templates = viewModel.commercializerTemplates(indexPath.row) else { return }
        guard let vm = PromoteProductViewModel(productId: productId, themes: templates, commercializers: nil,
                                               promotionSource: .settings) else { return }
        let vc = PromoteProductViewController(viewModel: vm)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}


// MARK: > PromoteProductViewControllerDelegate

extension CreateCommercialViewController: PromoteProductViewControllerDelegate {
    func promoteProductViewControllerDidFinishFromSource(_ promotionSource: PromotionSource) {
        navigationController?.popBackViewController()
    }
    
    func promoteProductViewControllerDidCancelFromSource(_ promotionSource: PromotionSource) {
    }
}


// MARK: > UICollectionViewDelegateFlowLayout

extension CreateCommercialViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 13, bottom: 13, right: 13)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width-39)/2
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
