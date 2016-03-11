//
//  UserViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift

class UserViewController: BaseViewController {
    private static let navBarUserViewHeight: CGFloat = 36
    private static let userBgViewDefaultHeight: CGFloat = 150

    private var navBarBgImage: UIImage?
    private var navBarShadowImage: UIImage?
    private var navBarUserView: UserView?

    @IBOutlet weak var patternView: UIView!
    @IBOutlet weak var userBgView: UIView!
    @IBOutlet weak var userBgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userBgEffectView: UIVisualEffectView!

    @IBOutlet weak var userAvatarImageView: UIImageView!

    @IBOutlet weak var userLabelsContainer: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userBgImageView: UIImageView!
    @IBOutlet weak var userBgTintView: UIView!

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainScrollContentView: UIView!


    private var viewModel : UserViewModel

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    init(viewModel: UserViewModel) {
        let size = CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight)
        self.navBarUserView = UserView.userView(.Compact(size: size))
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "UserViewController")

        self.viewModel.delegate = self

        hidesBottomBarWhenPushed = false
        automaticallyAdjustsScrollViewInsets = false
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
        let currentAlpha: CGFloat = viewModel.navBarUserInfoShowOnTop.value ? 1 : 0
        if let navBarUserView = navBarUserView {
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
}


// MARK: - Public methods

extension UserViewController {

}


// MARK: - UserViewModelDelegate

extension UserViewController: UserViewModelDelegate {

}


// MARK: - UIScrollViewDelegate

extension UserViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView == mainScrollView else { return }

        let percentage = scrollView.contentOffset.y / mainScrollContentView.frame.origin.y
        viewModel.setScrollPercentageRelativeToContent(percentage)

        userBgViewHeight.constant = max(UserViewController.userBgViewDefaultHeight, UserViewController.userBgViewDefaultHeight - scrollView.contentOffset.y)
    }
}


// MARK: - Private methods
// MARK: - UI

extension UserViewController {
    private func setupUI() {
        setupUserBgView()
        setupMainView()
        setupNavigationBar()
        setupUserAvatarView()
    }

    private func setupUserBgView() {
        userBgViewHeight.constant = UserViewController.userBgViewDefaultHeight
    }

    private func setupMainView() {
        guard let patternImage = UIImage(named: "pattern_transparent") else { return }
        patternView.backgroundColor = UIColor(patternImage: patternImage)
    }

    private func setupUserAvatarView() {
        userAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        userAvatarImageView.layer.borderWidth = 2
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.width / 2.0
        userAvatarImageView.clipsToBounds = true
    }

    private func setupNavigationBar() {
        if let navBarUserView = navBarUserView {
            navBarUserView.alpha = 0
            navBarUserView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight))
        }

        let backIcon = UIImage(named: "navbar_back_white_shadow")
        setLetGoNavigationBarStyle(navBarUserView, backIcon: backIcon)


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
        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.view.backgroundColor = bgColor
            self?.userBgTintView.backgroundColor = bgColor
        }.addDisposableTo(disposeBag)

        viewModel.navBarUserInfoShowOnTop.asObservable().distinctUntilChanged().subscribeNext { showOnTop in
            UIView.animateWithDuration(0.35) { [weak self] in
                let topAlpha: CGFloat = showOnTop ? 1 : 0
                let bottomAlpha: CGFloat = showOnTop ? 0 : 1
                self?.navBarUserView?.alpha = topAlpha
                self?.userLabelsContainer.alpha = bottomAlpha
                self?.userAvatarImageView.alpha = bottomAlpha
            }
        }.addDisposableTo(disposeBag)

        Observable.combineLatest(
            viewModel.userId.asObservable(),
            viewModel.userName.asObservable(),
            viewModel.userLocation.asObservable(),
            viewModel.userAvatarURL.asObservable()){$0}
        .subscribeNext { [weak self] (userId, userName, userLocation, userAvatar) in
            guard let navBarUserView = self?.navBarUserView else { return }
            navBarUserView.setupWith(userAvatar: userAvatar, userName: userName, userId: userId)
        }.addDisposableTo(disposeBag)

        viewModel.userBgViewHidden.asObservable().bindTo(userBgView.rx_hidden).addDisposableTo(disposeBag)
        viewModel.userBgEffectAlpha.asObservable().bindTo(userBgEffectView.rx_alpha).addDisposableTo(disposeBag)
        viewModel.userBgTintViewAlpha.asObservable().bindTo(userBgTintView.rx_alpha).addDisposableTo(disposeBag)
        
        viewModel.userName.asObservable().bindTo(userNameLabel.rx_optionalText).addDisposableTo(disposeBag)
        viewModel.userLocation.asObservable().bindTo(userLocationLabel.rx_optionalText).addDisposableTo(disposeBag)

        viewModel.userAvatarURL.asObservable().subscribeNext { [weak self] url in
            guard let strongSelf = self else { return }
            strongSelf.userAvatarImageView.sd_setImageWithURL(url,
                placeholderImage: strongSelf.viewModel.userAvatarPlaceholder.value)

            strongSelf.userBgImageView.sd_setImageWithURL(url)
        }.addDisposableTo(disposeBag)
    }
}
