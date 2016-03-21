//
//  UserViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import CHTCollectionViewWaterfallLayout
import LGCoreKit
import RxCocoa
import RxSwift

class UserViewController: BaseViewController {

    private static let navBarUserViewHeight: CGFloat = 36
    private static let userBgViewDefaultHeight: CGFloat = 106

    private static let headerExpandedHeaderTop: CGFloat = 110
    private static let headerCollapsedHeaderTop: CGFloat = -23  // 23 = 46/2, where: 46 = 40 image + 6 padding

    private static let collapsePercentageUserInfoSwitch: CGFloat = 0.3

    private static let userBgTintViewMaxAlpha: CGFloat = 0.7
    private static let userBgEffectViewMaxAlpha: CGFloat = 0.85

    private var navBarBgImage: UIImage?
    private var navBarShadowImage: UIImage?
    private var navBarUserView: UserView?

    @IBOutlet weak var patternView: UIView!
    @IBOutlet weak var userBgView: UIView!
    @IBOutlet weak var userBgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userBgEffectView: UIVisualEffectView!

    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var headerContainerViewTop: NSLayoutConstraint!
    var header: UserViewHeader?
    @IBOutlet weak var userCollectionView: UICollectionView!

    @IBOutlet weak var userLabelsContainer: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userBgImageView: UIImageView!
    @IBOutlet weak var userBgTintView: UIView!

    private let cellDrawer: ProductCellDrawer
    private var viewModel: UserViewModel
    private let disposeBag: DisposeBag


    private let headerCollapsePercentage = Variable<CGFloat>(0)


    // MARK: - Lifecycle

    init(viewModel: UserViewModel) {
        let size = CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight)
        self.navBarUserView = UserView.userView(.CompactBorder(size: size))
        self.header = UserViewHeader.userViewHeader()
        self.viewModel = viewModel
        self.cellDrawer = ProductCellDrawerFactory.drawerForProduct(true)
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: "UserViewController")

        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navBarBgImage = navigationController?.navigationBar.backgroundImageForBarMetrics(.Default)
        navBarShadowImage = navigationController?.navigationBar.shadowImage

        setupUI()
        setupRxBindings()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarStyle()

        // UINavigationBar's title alpha gets resetted on view appear, does not allow initial 0.0 value
        if let navBarUserView = navBarUserView {
            let currentAlpha: CGFloat = navBarUserView.alpha
            navBarUserView.hidden = true
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) {
                    navBarUserView.alpha = currentAlpha
                    navBarUserView.hidden = false
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        revertNavigationBarStyle()
    }

//    override var active: Bool {
//        didSet {
//            pages.forEach { $0.active = active }
//        }
//    }
}


// MARK: - Public methods

extension UserViewController {

}


// MARK: - CHTCollectionViewDelegateWaterfallLayout

extension UserViewController: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        heightForHeaderInSection section: Int) -> CGFloat {
            return 0
    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            return viewModel.sizeForCellAtIndex(indexPath.row)
    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        heightForFooterInSection section: Int) -> CGFloat {
            return Constants.productListFooterHeight
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: Constants.productListFixedInsets, left: Constants.productListFixedInsets,
                bottom: Constants.productListFixedInsets, right: Constants.productListFixedInsets)
    }
}

//
//public func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
//    heightForFooterInSection section: Int) -> CGFloat {
//        return Constants.productListFooterHeight
//}
//
//public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
//    insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: Constants.productListFixedInsets, left: Constants.productListFixedInsets,
//            bottom: Constants.productListFixedInsets, right: Constants.productListFixedInsets)
//}


// MARK: - LGViewPagerScrollDelegate

extension UserViewController: LGViewPagerScrollDelegate {
    func viewPager(viewPager: LGViewPager, didScrollToPagePosition pagePosition: CGFloat) {
        
    }
}

// MARK: - UserViewModelDelegate

extension UserViewController: UserViewModelDelegate {

}


// MARK: - UICollectionViewDataSource



//private enum CollectionViewBlabla {
//    case Section1
//    case
//}

extension UserViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3500
        case 1:
            return 0
        default:
            return 0
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        guard indexPath.section == 0 else { return cell }

        cell = cellDrawer.cell(collectionView, atIndexPath: indexPath)
        cell.tag = indexPath.hash
        let data = ProductCellData(title: "hola", price: "25 pavos", thumbUrl: nil, status: .Sold, date: nil, isFavorite: false, isMine: false, cellWidth: 300, indexPath: indexPath)
        cellDrawer.draw(cell, data: data, delegate: nil)

//        productListViewModel.setCurrentItemIndex(indexPath.item)
//        productListViewModel.visibleTopCellWithIndex(topProductIndex, whileScrollingDown: scrollingDown)

        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension UserViewController: UICollectionViewDelegate {
    
}

// MARK: - UIScrollViewDelegate

extension UserViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard userCollectionView == scrollView else { return }

        let minTop = UserViewController.headerCollapsedHeaderTop
        let maxTop = UserViewController.headerExpandedHeaderTop
        let top = maxTop - min(maxTop, maxTop + scrollView.contentOffset.y)

        headerContainerViewTop.constant = top + minTop
        userCollectionView.contentInset.top = min(maxTop, top)
        userCollectionView.scrollIndicatorInsets.top = top

        let percentage = 1 - (top / (maxTop - minTop))
        headerCollapsePercentage.value = percentage
    }
}


// MARK: - Private methods
// MARK: - UI

extension UserViewController {
    private func setupUI() {
        hidesBottomBarWhenPushed = false
        automaticallyAdjustsScrollViewInsets = false

        setupUserBgView()
        setupMainView()
        setupHeader()
        setupNavigationBar()
        setupCollectionView()
    }

    private func setupMainView() {
        guard let patternImage = UIImage(named: "pattern_transparent") else { return }
        patternView.backgroundColor = UIColor(patternImage: patternImage)
    }

    private func setupHeader() {
        guard let header = header else { return }
        header.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(header)

        let views = ["header": header]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[header]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(hConstraints)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[header]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(vConstraints)
    }

    private func setupNavigationBar() {
        if let navBarUserView = navBarUserView {
            navBarUserView.alpha = 0
            navBarUserView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight))
        }

        let backIcon = UIImage(named: "navbar_back_white_shadow")
        setLetGoNavigationBarStyle(navBarUserView, backIcon: backIcon)
    }

    private func setupUserBgView() {
        userBgViewHeight.constant = UserViewController.userBgViewDefaultHeight
    }

    private func setupCollectionView() {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        userCollectionView.collectionViewLayout = layout
//        userCollectionView.collectionViewLayout

        userCollectionView.backgroundColor = UIColor.clearColor()
        userCollectionView.backgroundView = nil
        userCollectionView.contentInset.top = UserViewController.headerExpandedHeaderTop
        userCollectionView.scrollIndicatorInsets.top = UserViewController.headerExpandedHeaderTop
        userCollectionView.delegate = self
        userCollectionView.dataSource = self

        ProductCellDrawerFactory.registerCells(userCollectionView)
    }

    private func setNavigationBarStyle() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }

    private func revertNavigationBarStyle() {
        navigationController?.navigationBar.setBackgroundImage(navBarBgImage, forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = navBarShadowImage
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
}


// MARK: - Rx

extension UserViewController {
    private func setupRxBindings() {
        setupBackgroundBindings()
        setupNavBarRxBindings()
        setupHeaderRxBindings()
    }

    private func setupBackgroundBindings() {
        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.view.backgroundColor = bgColor
            self?.userBgTintView.backgroundColor = bgColor
        }.addDisposableTo(disposeBag)
    }

    private func setupNavBarRxBindings() {
        Observable.combineLatest(
            viewModel.userId.asObservable(),
            viewModel.userName.asObservable(),
            viewModel.userLocation.asObservable(),
            viewModel.userAvatarURL.asObservable()) { $0 }
        .subscribeNext { [weak self] (userId, userName, userLocation, userAvatar) in
            guard let navBarUserView = self?.navBarUserView else { return }
            navBarUserView.setupWith(userAvatar: userAvatar, userName: userName, subtitle: userLocation, userId: userId)
        }.addDisposableTo(disposeBag)
    }

    private func setupHeaderRxBindings() {



        // Pattern overlay is hidden if there's no avatar
        viewModel.userAvatarURL.asObservable().map { $0 != nil }
            .bindTo(patternView.rx_hidden)
            .addDisposableTo(disposeBag)

        // User bg view overlay is hidden if there's no avatar
        viewModel.userAvatarURL.asObservable().map { $0 == nil }
            .bindTo(userBgView.rx_hidden)
            .addDisposableTo(disposeBag)


        viewModel.userName.asObservable().bindTo(userNameLabel.rx_optionalText).addDisposableTo(disposeBag)
        viewModel.userLocation.asObservable().bindTo(userLocationLabel.rx_optionalText).addDisposableTo(disposeBag)
        viewModel.userAvatarURL.asObservable().subscribeNext { [weak self] url in
            guard let strongSelf = self else { return }
            strongSelf.header?.setAvatar(url, placeholderImage: strongSelf.viewModel.userAvatarPlaceholder.value)
            strongSelf.userBgImageView.sd_setImageWithURL(url)
        }.addDisposableTo(disposeBag)

        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.header?.indicatorSelectedColor = bgColor
        }.addDisposableTo(disposeBag)

        // Header collapse notify percentage
        let percentage = headerCollapsePercentage.asObservable().map {
            return max(0, min(1, $0))
        }
        percentage.subscribeNext { [weak self] percentage in
            self?.header?.setCollapsePercentage(percentage)
        }.addDisposableTo(disposeBag)

        headerCollapsePercentage.asObservable().map { percentage in
            return UserViewController.userBgViewDefaultHeight * (1 + (1 - percentage))
        }.bindTo(userBgViewHeight.rx_constant).addDisposableTo(disposeBag)

        headerCollapsePercentage.asObservable()
            .subscribeNext { [weak self] percentage in
                print(percentage)
                self?.userBgEffectView.alpha = min(percentage + 0.7, UserViewController.userBgEffectViewMaxAlpha)
                self?.userBgTintView.alpha = min(percentage + 0.2, UserViewController.userBgTintViewMaxAlpha)
            }
            .addDisposableTo(disposeBag)

        // Header collapse switch
        headerCollapsePercentage.asObservable().map {
            $0 >= UserViewController.collapsePercentageUserInfoSwitch
        }.distinctUntilChanged().subscribeNext { [weak self] collapsed in
            self?.header?.setAvatarHidden(collapsed)

            UIView.animateWithDuration(0.2) { [weak self] in
                let topAlpha: CGFloat = collapsed ? 1 : 0
                let bottomAlpha: CGFloat = collapsed ? 0 : 1
                self?.navBarUserView?.alpha = topAlpha
                self?.userLabelsContainer.alpha = bottomAlpha
            }
        }.addDisposableTo(disposeBag)
    }
}
