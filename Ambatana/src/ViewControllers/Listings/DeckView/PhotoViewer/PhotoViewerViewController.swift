//
//  PhotoViewerViewController.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

final class PhotoViewerViewController: KeyboardViewController, PhotoViewerVCType, UICollectionViewDataSource, UICollectionViewDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle { return .default }

    @available(iOS 11.0, *)
    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge { return [.left, .top] }

    let chatView: QuickChatView
    let photoViewer = PhotoViewerView()
    private let viewModel: PhotoViewerViewModel
    private let binder = PhotoViewerViewControllerBinder()

    private var edgeGestures: [UIGestureRecognizer] = []
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var swipeGestureRecognizer: UISwipeGestureRecognizer?

    init(viewModel: PhotoViewerViewModel, quickChatViewModel: QuickChatViewModel) {
        self.viewModel = viewModel
        self.chatView = QuickChatView(chatViewModel: quickChatViewModel)
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { self.view = photoViewer }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        setupViewExtendedEdges()
        setupPhotoViewer()
    }

    private func setupViewExtendedEdges() {
        if #available(iOS 11.0, *) {
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        } else {
            setNeedsStatusBarAppearanceUpdate()
        }
        edgesForExtendedLayout = .all
        automaticallyAdjustsScrollViewInsets = false
    }

    private func setupPhotoViewer() {
        photoViewer.register(ListingDeckImagePreviewCell.self,
                             forCellWithReuseIdentifier: ListingDeckImagePreviewCell.reusableID)
        photoViewer.dataSource = self
        photoViewer.updateNumberOfPages(viewModel.itemsCount)

        binder.viewController = self
        binder.bind(toView: photoViewer)
    }

    private func setupDismissChatGestures() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissChat))
        swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissChat))
        swipeGestureRecognizer?.direction = .down
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chatView.resignFirstResponder()
        chatView.removeFromSuperview()
    }

    // MARK: NavBar

    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        setLeftCloseButton()
        setNavigationBarRightButtons([])
    }

    private func hideLeftButton() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem()
    }

    private func setLeftCloseButton() {
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_carousel"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(closeView))
        self.navigationItem.leftBarButtonItem  = leftButton
    }

    private func updateCurrentPage(_ currentPage: Int) {
        photoViewer.updateCurrentPage(currentPage)
    }

    func updateWith(keyboardChange: KeyboardChange) {
        let height = photoViewer.bounds.height - keyboardChange.origin
        chatView.updateWith(bottomInset: height,
                            animationTime: TimeInterval(keyboardChange.animationTime),
                            animationOptions: keyboardChange.animationOptions,
                            completion:  { [weak self] completion in
                                if height <= 0 {
                                    self?.chatView.removeFromSuperview()
                                }})
    }

    func updatePage(fromContentOffset offset: CGFloat) {
        updateCurrentPage(pageIndex(fromContentOffset: offset))
    }

    private func pageIndex(fromContentOffset offset: CGFloat) -> Int {
        let width = photoViewer.width
        guard width > 0 else { return 0 }
        let page = offset / width
        return Int(page)
    }

    func showChat() {
        hideLeftButton()

        chatView.frame = photoViewer.frame
        chatView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatView)
        chatView.layout(with: photoViewer).fill()
        
        view.setNeedsLayout()
        view.layoutIfNeeded()

        chatView.becomeFirstResponder()

        addDissmisGestureRecognizers()
    }

    private func addDissmisGestureRecognizers() {
        if tapGestureRecognizer == nil || swipeGestureRecognizer == nil {
            setupDismissChatGestures()
        }
        guard let gesture = tapGestureRecognizer else { return }
        chatView.addDismissGestureRecognizer(gesture)
        guard let swipe = swipeGestureRecognizer else { return }
        chatView.addGestureRecognizer(swipe)
    }

    @objc func closeView() {
        viewModel.dismiss()
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: ListingDeckImagePreviewCell.reusableID,
                                                       for: indexPath)
        guard let imageCell = cell as? ListingDeckImagePreviewCell,
            let url = viewModel.urlsAtIndex(indexPath.row) else {
                return UICollectionViewCell()
        }
        imageCell.tag = indexPath.row
        guard let cache = viewModel.imageDownloader.cachedImageForUrl(url) else {
            _ = ImageDownloader.sharedInstance.downloadImageWithURL(url) { (result, url) in
                if let value = result.value, imageCell.tag == indexPath.row {
                    imageCell.imageURL = url
                    imageCell.imageView.image = value.image
                }
            }
            return cell
        }
        imageCell.imageView.image = cache
        return imageCell
    }

    // MARK: Actions

    @objc func dismissChat() {
        if let gesture = tapGestureRecognizer {
            chatView.removeGestureRecognizer(gesture)
        }
        chatView.resignFirstResponder()
        setLeftCloseButton()
    }

    // MARK: UIGestureRecognizer

    func addEdgeGesture(_ edgeGestures: [UIGestureRecognizer]) {
        edgeGestures.forEach { view.removeGestureRecognizer($0) }
        self.edgeGestures = edgeGestures
        edgeGestures.forEach { view.addGestureRecognizer($0) }
    }

}
