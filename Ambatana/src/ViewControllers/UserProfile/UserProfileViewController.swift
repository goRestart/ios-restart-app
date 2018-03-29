//
//  UserProfileViewController.swift
//  LetGo
//
//  Created by Sergi Gracia on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import LGCoreKit

final class UserProfileViewController: BaseViewController {

    // Data

    private let viewModel: UserProfileViewModel
    private let disposeBag: DisposeBag
    private let socialSharer: SocialSharer

    // UI
    private let headerContainerView = UIView()
    private let headerView: UserProfileHeaderView
    private let navBarUserView = UserProfileNavBarUserView()
    private let userRelationView = UserProfileRelationView()
    private let bioAndTrustView: UserProfileBioAndTrustView
    private let dummyView = UserProfileDummyUserDisclaimerView()
    private let tabsView = UserProfileTabsView()
    private let listingView: ListingListView
    private let tableView = UITableView()

    private let headerGestureRecognizer = UIPanGestureRecognizer()

    private var headerContainerTopConstraint: NSLayoutConstraint?
    private var userRelationViewHeightConstraint: NSLayoutConstraint?
    private var dummyViewHeightConstraint: NSLayoutConstraint?
    private var updatingUserRelation: Bool = false

    private var scrollableContentInset: UIEdgeInsets {
        return UIEdgeInsets(top: Layout.topMargin + headerContainerView.height, left: 0, bottom: 0, right: 0)
    }

    private var listingViewAdjustedContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return listingView.collectionView.adjustedContentInset
        } else {
            return listingView.collectionView.contentInset
        }
    }

    private var tableViewAdjustedContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return tableView.adjustedContentInset
        } else {
            return tableView.contentInset
        }
    }

    private let userNavBarAnimationDelta: CGFloat = 40.0
    private let userNavBarAnimationStartOffset: CGFloat = 44.0

    private struct Layout {
        static let sideMargin: CGFloat = Metrics.bigMargin
        static let topMargin: CGFloat = Metrics.bigMargin
        static let tabsHeight: CGFloat = 54.0
        static let userRelationHeight: CGFloat = 48
        static let dummyDisclaimerHeight: CGFloat = 50
        static let headerBottomMargin: CGFloat = Metrics.margin
    }

    // MARK: - Lifecycle

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: UserProfileViewModel, hidesBottomBarWhenPushed: Bool, socialSharer: SocialSharer) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        self.headerView = UserProfileHeaderView(isPrivate: viewModel.isPrivateProfile)
        self.bioAndTrustView = UserProfileBioAndTrustView(isPrivate: viewModel.isPrivateProfile)
        self.listingView = ListingListView(viewModel: ListingListViewModel(requester: nil),
                                           featureFlags: FeatureFlags.sharedInstance,
                                           frame: .zero)
        self.socialSharer = socialSharer
        self.socialSharer.delegate = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.ratingListViewModel.delegate = self
        viewModel.delegate = self
        self.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        self.automaticallyAdjustsScrollViewInsets = false
        hasTabBar = viewModel.isPrivateProfile
    }

    convenience init(viewModel: UserProfileViewModel, hidesBottomBarWhenPushed: Bool = false) {
        self.init(viewModel: viewModel,
                  hidesBottomBarWhenPushed: hidesBottomBarWhenPushed,
                  socialSharer: SocialSharer())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupRx()
        setupHeaderRxBindings()
        setupPushPermissionsRx()
        setupAccessibilityIds()
        setupContent()
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let isHeaderResizing = bioAndTrustView.isAnimatingResize.value
        if isHeaderResizing || updatingUserRelation {
            updateUIBasedOnHeaderResize()
        } else {
            updateUIBasedOnContentOffset()
        }
    }

    // MARK: Component setup

    private func setupUI() {
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false

        headerContainerView.addSubviewsForAutoLayout([headerView, dummyView, userRelationView,
                                                      bioAndTrustView, tabsView])
        view.addSubviewsForAutoLayout([tableView, listingView, headerContainerView])

        navBarUserView.translatesAutoresizingMaskIntoConstraints = false
        navBarUserView.alpha = 0
        tabsView.delegate = self

        headerContainerView.backgroundColor = .white
        headerContainerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        headerContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        headerContainerView.layer.shadowRadius = 4.0

        listingView.scrollDelegate = self
        listingView.headerDelegate = self
        listingView.refreshControl.removeFromSuperview()
        listingView.shouldScrollToTopOnFirstPageReload = false
        listingView.collectionView.showsVerticalScrollIndicator = false

        headerGestureRecognizer.addTarget(self, action: #selector(handleScrollingGestureRecognizer))
        headerContainerView.addGestureRecognizer(headerGestureRecognizer)

        listingView.collectionView.clipsToBounds = true
        listingView.clipsToBounds = true

        setupRatingsTableView()
        setupConstraints()
    }

    private func setupRatingsTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        let cellNib = UINib(nibName: UserRatingCell.reusableID, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: UserRatingCell.reusableID)
    }

    private func setupNavBar() {
        let backIcon = UIImage(named: "navbar_back_red")
        setNavBarBackButton(backIcon)

        self.navigationItem.titleView = navBarUserView

        // The right buttons array depends on the isMyUser flag so we need to subsribe to those changes
        viewModel
            .isMyUser
            .asDriver()
            .distinctUntilChanged()
            .drive(onNext: setupNavBarRightActions)
            .disposed(by: disposeBag)
    }

    func setupNavBarRightActions(isMyUser: Bool) {
        var rightButtons: [UIButton] = []

        let shareIcon = UIImage(named: "navbar_share_red")?.withRenderingMode(.alwaysOriginal)
        let shareButton = UIButton(type: .system)
        shareButton.setImage(shareIcon, for: .normal)
        shareButton.addTarget(self, action: #selector(didTapOnNavBarShare), for: .touchUpInside)
        rightButtons.append(shareButton)

        if self.viewModel.isPrivateProfile {
            let settingsIcon = UIImage(named: "navbar_settings_red")?.withRenderingMode(.alwaysOriginal)
            let settingsButton = UIButton(type: .system)
            settingsButton.setImage(settingsIcon, for: .normal)
            settingsButton.addTarget(self, action: #selector(didTapOnNavBarSettings), for: .touchUpInside)
            rightButtons.append(settingsButton)
        }

        if !isMyUser
            && !viewModel.isPrivateProfile
            && viewModel.isLoggedInUser {
            let moreIcon = UIImage(named: "navbar_more_red")?.withRenderingMode(.alwaysOriginal)
            let moreButton = UIButton(type: .system)
            moreButton.setImage(moreIcon, for: .normal)
            moreButton.addTarget(self, action: #selector(didTapOnNavBarMore), for: .touchUpInside)
            rightButtons.append(moreButton)
        }

        self.setNavigationBarRightButtons(rightButtons)
    }

    private func setupConstraints() {

        var constraints = [
            headerContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            headerView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            headerView.leftAnchor.constraint(equalTo: headerContainerView.leftAnchor, constant: Layout.sideMargin),
            headerView.rightAnchor.constraint(equalTo: headerContainerView.rightAnchor, constant: -Layout.sideMargin),
            dummyView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Layout.headerBottomMargin),
            dummyView.leftAnchor.constraint(equalTo: headerContainerView.leftAnchor, constant: Metrics.shortMargin),
            dummyView.rightAnchor.constraint(equalTo: headerContainerView.rightAnchor, constant: -Metrics.shortMargin),
            userRelationView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Layout.headerBottomMargin),
            userRelationView.leftAnchor.constraint(equalTo: headerContainerView.leftAnchor, constant: Layout.sideMargin),
            userRelationView.rightAnchor.constraint(equalTo: headerContainerView.rightAnchor, constant: -Layout.sideMargin),
            bioAndTrustView.topAnchor.constraint(equalTo: userRelationView.bottomAnchor, constant: 0) ,
            bioAndTrustView.leftAnchor.constraint(equalTo: headerContainerView.leftAnchor, constant: Layout.sideMargin),
            bioAndTrustView.rightAnchor.constraint(equalTo: headerContainerView.rightAnchor, constant: -Layout.sideMargin),
            bioAndTrustView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -Layout.tabsHeight),
            tabsView.leftAnchor.constraint(equalTo: headerContainerView.leftAnchor, constant: Layout.sideMargin),
            tabsView.rightAnchor.constraint(equalTo: headerContainerView.rightAnchor, constant: -Layout.sideMargin),
            tabsView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            tabsView.heightAnchor.constraint(equalToConstant: Layout.tabsHeight),
            listingView.topAnchor.constraint(equalTo: safeTopAnchor),
            listingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            listingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            listingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: safeTopAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        let headerContainerTop =  headerContainerView.topAnchor.constraint(equalTo: safeTopAnchor, constant: Layout.topMargin)
        headerContainerTopConstraint = headerContainerTop
        constraints.append(headerContainerTop)

        let userRelationViewHeight = userRelationView.heightAnchor.constraint(equalToConstant: 0)
        userRelationViewHeightConstraint = userRelationViewHeight
        constraints.append(userRelationViewHeight)

        let dummyViewHeight = dummyView.heightAnchor.constraint(equalToConstant: 0)
        dummyViewHeightConstraint = dummyViewHeight
        constraints.append(dummyViewHeight)

        headerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        bioAndTrustView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        tabsView.setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate(constraints)
    }

    private func setupContent() {
        headerView.delegate = self
        bioAndTrustView.delegate = self
        bioAndTrustView.buildTrustButtonTitle = LGLocalizedString.profileBuildTrustButton
        bioAndTrustView.addBioButtonTitle = "+ " + LGLocalizedString.profileBioAddButton
        bioAndTrustView.verifiedTitleText = LGLocalizedString.profileVerifiedAccountsTitle
        bioAndTrustView.moreBioButtonTitle = LGLocalizedString.profileBioShowMoreButton

        var tabs = [UserProfileTabValue(type: .selling), UserProfileTabValue(type: .sold)]
        if viewModel.isPrivateProfile {
            tabs.append(UserProfileTabValue(type: .favorites))
        }
        tabs.append(UserProfileTabValue(type: .reviews))
        tabsView.setupTabs(tabs: tabs)
    }

    private func setupAccessibilityIds() {
        navBarUserView.userNameLabel.set(accessibilityId: .userHeaderCollapsedNameLabel)
        listingView.firstLoadView.set(accessibilityId: .userListingsFirstLoad)
        listingView.collectionView.set(accessibilityId: .userListingsList)
        listingView.errorView.set(accessibilityId: .userListingsError)
    }

    // MARK: - UI

    private func updateUIBasedOnHeaderResize() {
        let previousInset = listingView.collectionViewContentInset
        let offset = listingView.collectionView.contentOffset.y + previousInset.top - scrollableContentInset.top

        tableView.contentInset = scrollableContentInset
        listingView.collectionViewContentInset = scrollableContentInset

        listingView.collectionView.contentOffset.y = offset
        tableView.contentOffset.y = offset
        updatingUserRelation = false
    }

    private func updateUIBasedOnContentOffset() {
        tableView.contentInset = scrollableContentInset
        listingView.collectionViewContentInset = scrollableContentInset
        listingView.firstLoadPadding = scrollableContentInset
        listingView.errorPadding = scrollableContentInset

        let contentInset: UIEdgeInsets
        let contentOffset: CGPoint

        switch viewModel.selectedTab.value {
        case .selling, .sold, .favorites:
            contentInset = listingViewAdjustedContentInset
            contentOffset = listingView.collectionView.contentOffset
            tableView.contentOffset.y = contentOffset.y
        case .reviews:
            contentInset = tableViewAdjustedContentInset
            contentOffset = tableView.contentOffset
            listingView.collectionView.contentOffset.y = contentOffset.y
        }

        updateHeaderContainerView(contentOffset: contentOffset, contentInset: contentInset)
        updateNavBarUserView(contentOffset: contentOffset)
        updateScrollableContentSize()
    }

    private func updateHeaderContainerView(contentOffset: CGPoint, contentInset: UIEdgeInsets) {
        let headerTopMargin = Layout.topMargin
        let relativeHeaderTop = headerTopMargin - (contentInset.top + contentOffset.y)
        let minPositionForVisibleTabs = -(headerContainerView.height - tabsView.height)
        let headerTop = min(headerTopMargin, max(relativeHeaderTop, minPositionForVisibleTabs))

        headerContainerTopConstraint?.constant = headerTop
        headerContainerView.layer.shadowOpacity = relativeHeaderTop < minPositionForVisibleTabs ? 1.0 : 0.0
    }

    private func updateNavBarUserView(contentOffset: CGPoint) {
        let startAlphaAnimation = scrollableContentInset.top - userNavBarAnimationStartOffset
        let normalizedAlphaLength = 1 / userNavBarAnimationDelta
        let normalizedAlphaPosition = -contentOffset.y - startAlphaAnimation
        let invertedAlpha = normalizedAlphaLength * normalizedAlphaPosition
        let alpha = 1 - invertedAlpha

        navBarUserView.isHidden = alpha <= 0
        navBarUserView.alpha = alpha
    }

    private func updateScrollableContentSize() {
        let topSpace = listingViewAdjustedContentInset.top - scrollableContentInset.top
        let bottomSpace = listingViewAdjustedContentInset.bottom
        listingView.minimumContentHeight = listingView.collectionView.height
            - topSpace
            - bottomSpace
            - tabsView.height
        if tableView.contentSize.height < listingView.minimumContentHeight {
            tableView.contentSize.height = listingView.minimumContentHeight
        }
    }
}

// MARK: - NavigationBar actions

extension UserProfileViewController {
    @objc private func didTapOnNavBarShare() {
        viewModel.didTapShareButton()
    }

    @objc private func didTapOnNavBarSettings() {
        viewModel.didTapSettingsButton()
    }

    @objc private func didTapOnNavBarMore() {
        let reportAction = UIAction(interface: .text(LGLocalizedString.reportUserTitle),
                                    action: viewModel.didTapReportUserButton)
        let unblockAction = UIAction(interface: .text(LGLocalizedString.chatUnblockUser),
                                     action: viewModel.didTapUnblockUserButton)
        let blockAction = UIAction(interface: .text(LGLocalizedString.chatBlockUser),
                                   action: viewModel.didTapBlockUserButton)

        let alternativeAction = viewModel.userRelationIsBlocked.value ? unblockAction : blockAction

        showActionSheet(LGLocalizedString.commonCancel, actions: [reportAction, alternativeAction])
    }
}

// MARK: - Tabs Delegate

extension UserProfileViewController: UserProfileTabsViewDelegate {
    func didSelect(tab: UserProfileTabType) {
        viewModel.selectedTab.value = tab
        listingView.isHidden = tab == .reviews
        tableView.isHidden = tab != .reviews
    }
}

// MARK: - Bio And Trust Delegate

extension UserProfileViewController: UserProfileBioAndTrustDelegate {
    func didTapBuildTrust() {
        viewModel.didTapBuildTrustButton()
    }

    func didTapAddBio() {
        viewModel.didTapEditBioButton()
    }
}

// MARK: - Header Delegate

extension UserProfileViewController: UserProfileHeaderDelegate {
    func didTapEditAvatar() {
        guard viewModel.isPrivateProfile else { return }
        MediaPickerManager.showImagePickerIn(self)
    }

    func didTapAvatar() {}
}

// MARK: - Image Picker Delegate

extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        dismiss(animated: true, completion: nil)
        guard let theImage = image else { return }
        viewModel.updateAvatar(with: theImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Ratings TableView Delegate & DataSource

extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ratingListViewModel.objectCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserRatingCell.reusableID,
                                                       for: indexPath) as? UserRatingCell else
        { return UITableViewCell() }

        guard let data = viewModel.ratingListViewModel.dataForCellAtIndexPath(indexPath) else { return UITableViewCell() }
        cell.setupRatingCellWithData(data, indexPath: indexPath)
        cell.delegate = viewModel.ratingListViewModel
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        viewModel.ratingListViewModel.setCurrentIndex(indexPath.row)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.setNeedsLayout()
    }
}

// MARK: - Ratings ViewModel Delegate

extension UserProfileViewController: UserRatingListViewModelDelegate {
    func vmIsLoadingUserRatingsRequest(_ isLoading: Bool, firstPage: Bool) {}
    func vmDidFailLoadingUserRatings(_ firstPage: Bool) {}

    func vmDidLoadUserRatings(_ ratings: [UserRating]) {
        guard !ratings.isEmpty else { return }
        tableView.reloadData()
    }

    func vmRefresh() {
        tableView.reloadData()
    }
}

// MARK: - Rx

extension UserProfileViewController {
    private func setupRx() {
        viewModel
            .listingListViewModel
            .drive(onNext: { [weak self] in
                guard let vm = $0 else { return }
                self?.listingView.switchViewModel(vm)
            })
            .disposed(by: disposeBag)
    }

    private func setupHeaderRxBindings() {
        viewModel
            .userName
            .drive(onNext: { [weak self] userName in
                self?.headerView.userNameLabel.text = userName
                self?.navBarUserView.userNameLabel.text = userName
            })
            .disposed(by: disposeBag)

        viewModel
            .userRatingAverage
            .drive(onNext: { [weak self] in
                self?.headerView.ratingView.setupValue(rating: $0)
                self?.navBarUserView.userRatingView.setupValue(rating: $0)
            })
            .disposed(by: disposeBag)

        Observable
            .combineLatest(viewModel.userAvatarURL.asObservable(), viewModel.userAvatarPlaceholder.asObservable()) { ($0, $1) }
            .subscribeNext { [weak self] (url, placeholder) in
                self?.headerView.setAvatar(url, placeholderImage: placeholder)
            }
            .disposed(by: disposeBag)

        viewModel
            .userAccounts
            .drive(onNext: { [weak self] accounts in
                self?.bioAndTrustView.accounts = accounts
            })
            .disposed(by: disposeBag)

        viewModel
            .userLocation
            .drive(onNext: { [weak self] location in
                self?.headerView.locationLabel.text = location
            })
            .disposed(by: disposeBag)

        viewModel
            .userBio
            .drive(onNext: { [weak self] bio in
                self?.bioAndTrustView.userBio = bio
            })
            .disposed(by: disposeBag)

        viewModel
            .userMemberSinceText
            .drive(onNext: { [weak self] memberSince in
                self?.headerView.memberSinceLabel.text = memberSince
            })
            .disposed(by: disposeBag)

        viewModel
            .userRelationText
            .drive(onNext: { [weak self] text in
                self?.updateUserRelation(with: text)
            })
            .disposed(by: disposeBag)

        Driver
            .combineLatest(viewModel.userIsDummy, viewModel.userName) { ($0, $1) }
            .drive(onNext: { [weak self] (isDummy, userName) in
                self?.updateDummyUsersView(isDummy: isDummy, userName: userName)
            })
            .disposed(by: disposeBag)
    }

    private func setupPushPermissionsRx() {
        viewModel
            .arePushNotificationsEnabled
            .asDriver()
            .filter { $0 != nil }
            .drive(onNext: { [weak self] _ in
                self?.didChangePushPermissions()
            })
            .disposed(by: disposeBag)
    }

    private func updateUserRelation(with text: String?) {
        updatingUserRelation = true
        userRelationView.userRelationText = text
        userRelationViewHeightConstraint?.constant = text == nil ? 0 : Layout.userRelationHeight
        headerContainerView.setNeedsLayout()
    }

    private func updateDummyUsersView(isDummy: Bool, userName: String?) {
        guard let user = userName else { return }
        dummyView.isHidden = !isDummy
        if isDummy {
            tabsView.isHidden = true
            bioAndTrustView.isHidden = true
            listingView.isHidden = true
            tableView.isHidden = true
            userRelationView.isHidden = true
        }
        dummyViewHeightConstraint?.constant = isDummy ? Layout.dummyDisclaimerHeight : 0
        dummyView.infoText = LGLocalizedString.profileDummyUserInfo(user)
    }
}

// MARK: - Scrolling Coordination

extension UserProfileViewController: ListingListViewScrollDelegate {

    func listingListView(_ listingListView: ListingListView, didScrollDown scrollDown: Bool) {}

    func listingListView(_ listingListView: ListingListView, didScrollWithContentOffsetY contentOffsetY: CGFloat) {
        view.setNeedsLayout()
    }

    func listingListViewAllowScrollingOnEmptyState(_ listingListView: ListingListView) -> Bool {
        return true
    }

    @objc private func handleScrollingGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        gestureRecognizer.setTranslation(CGPoint.zero, in: view)

        let relativeOffset = listingView.collectionView.contentOffset.y - translation.y
        let minOffset = -listingViewAdjustedContentInset.top
        let maxOffset = scrollableContentInset.top
        let draggedContentOffest = min(maxOffset, max(minOffset, relativeOffset))

        // Coordinate drag movement with scrollable content offsets
        listingView.collectionView.contentOffset.y = draggedContentOffest
        tableView.contentOffset.y = draggedContentOffest
    }
}

// MARK: - ViewModel Delegate

extension UserProfileViewController: UserProfileViewModelDelegate {
    func vmShowNativeShare(_ socialMessage: SocialMessage) {
        socialSharer.share(socialMessage,
                           shareType: .native(restricted: false),
                           viewController: self,
                           barButtonItem: navigationItem.rightBarButtonItems?.first)
    }
}

// MARK: - PushPermissions and MostSearched Banners

extension UserProfileViewController: ListingListViewHeaderDelegate, PushPermissionsHeaderDelegate, MostSearchedItemsUserHeaderDelegate {

    private func didChangePushPermissions() {
        listingView.refreshDataView()
    }

    func totalHeaderHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        totalHeight += viewModel.showPushPermissionsBanner ? PushPermissionsHeader.viewHeight : 0
        totalHeight += viewModel.showMostSearchedItemsBanner ? MostSearchedItemsUserHeader.viewHeight : 0
        return totalHeight
    }

    func setupViewsIn(header: ListHeaderContainer) {
        header.clear()
        if viewModel.showPushPermissionsBanner {
            let pushHeader = PushPermissionsHeader()
            pushHeader.tag = 0
            pushHeader.delegate = self
            header.addHeader(pushHeader, height: PushPermissionsHeader.viewHeight, style: .bubble)
        }
        if viewModel.showMostSearchedItemsBanner {
            let mostSearchedItemsHeader = MostSearchedItemsUserHeader()
            mostSearchedItemsHeader.tag = 1
            mostSearchedItemsHeader.delegate = self
            header.addHeader(mostSearchedItemsHeader, height: MostSearchedItemsUserHeader.viewHeight)
        }
    }

    func pushPermissionHeaderPressed() {
        viewModel.didTapPushPermissionsBanner()
    }

    func didTapMostSearchedItemsHeader() {
        viewModel.didTapMostSearchedItems()
    }
}
