//
//  PhotoViewerViewController.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

final class PhotoViewerViewController: KeyboardViewController, PhotoViewerVCType, UICollectionViewDataSource, UICollectionViewDelegate {
    override var prefersStatusBarHidden: Bool { return true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .fade }

    @available(iOS 11.0, *)
    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge { return [.left, .top] }

    let chatView: QuickChatView?
    let photoViewer = PhotoViewerView()

    private let chatButton = ChatButton()

    private let viewModel: PhotoViewerViewModel
    private let binder = PhotoViewerViewControllerBinder()

    private var edgeGestures: [UIGestureRecognizer] = []
    private let quickChatTap = UITapGestureRecognizer()

    init(viewModel: PhotoViewerViewModel, quickChatViewModel: QuickChatViewModel) {
        self.viewModel = viewModel
        self.chatView = QuickChatView(chatViewModel: quickChatViewModel)
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { self.view = photoViewer }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainResponder = chatView?.textView
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupUI() {
        setupViewExtendedEdges()
        setupPhotoViewer()
        setupChatbutton()
        setupGestures()

        chatView?.textViewStandardColor = .white
    }

    private func setupChatbutton() {
        view.addSubviewForAutoLayout(chatButton)

        chatButton.layout(with: view)
            .leadingMargin(by: Metrics.margin)
            .bottomMargin(by: -Metrics.bigMargin)

        chatButton.addTarget(self, action: #selector(showChatFromButton), for: .touchUpInside)
        chatButton.isHidden = !viewModel.isChatEnabled
    }

    private func setupViewExtendedEdges() {
        if #available(iOS 11.0, *) {
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
        edgesForExtendedLayout = .all
        automaticallyAdjustsScrollViewInsets = false
    }

    private func setupPhotoViewer() {
        photoViewer.register(ListingDeckVideoCell.self,
                             forCellWithReuseIdentifier: ListingDeckVideoCell.reusableID)
        photoViewer.register(ListingDeckImagePreviewCell.self,
                             forCellWithReuseIdentifier: ListingDeckImagePreviewCell.reusableID)

        photoViewer.dataSource = self
        photoViewer.delegate = self
        photoViewer.updateNumberOfPages(viewModel.itemsCount)

        binder.viewController = self
        binder.bind(toView: photoViewer)
    }

    private func setupGestures() {
        if viewModel.isChatEnabled {
            setupOpenChatGesture()
            setupDismissChatGestures()
        }
        setupSwipeToDismiss()
    }

    private func setupSwipeToDismiss() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissView))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }

    private func setupOpenChatGesture() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(showChat))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
    }

    private func setupDismissChatGestures() {
        quickChatTap.addTarget(self, action: #selector(dismissChat))
        chatView?.addDismissGestureRecognizer(quickChatTap)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissChat))
        swipeDown.direction = .down
        chatView?.addGestureRecognizer(swipeDown)
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
        if viewModel.mediaAtIndexIsPlayable(photoViewer.currentPage) {
            photoViewer.resumeVideoCurrentPage()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chatView?.resignFirstResponder()
        chatView?.removeFromSuperview()
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
        let height = view.bounds.height - keyboardChange.origin
        chatView?.updateWith(bottomInset: height,
                            animationTime: TimeInterval(keyboardChange.animationTime),
                            animationOptions: keyboardChange.animationOptions,
                            completion:  { [weak self] completion in
                                if height <= 0 {
                                    self?.chatView?.removeFromSuperview()
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

    @objc func showChatFromButton() {
        chatButton.bounce { [weak self] in
            self?.showChat()
        }
    }

    @objc func showChat() {
        guard let chatView = chatView else { return }

        viewModel.didOpenChat()
        hideLeftButton()
        chatView.frame = photoViewer.frame
        view.addSubviewForAutoLayout(chatView)
        view.bringSubview(toFront: chatView)

        chatView.layout(with: view).fill()

        view.setNeedsLayout()
        view.layoutIfNeeded()

        chatView.becomeFirstResponder()
    }

    @objc func closeView() {
        viewModel.dismiss()
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let media = viewModel.mediaAtIndex(indexPath.row) else { return UICollectionViewCell() }
        if media.isPlayable && viewModel.shouldShowVideos {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListingDeckVideoCell.reusableID,
                                                                for: indexPath) as? ListingDeckVideoCell else {
                                                                    return UICollectionViewCell() }


            cell.play(previewURL: media.outputs.videoThumbnail, videoURL: media.outputs.video)
            return cell
        } else {
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: ListingDeckImagePreviewCell.reusableID,
                                                           for: indexPath)
            guard let imageCell = cell as? ListingDeckImagePreviewCell,
                let url = viewModel.urlsAtIndex(indexPath.row) else {
                    return UICollectionViewCell()
            }
            imageCell.tag = indexPath.row
            guard let cache = viewModel.imageDownloader.cachedImageForUrl(url) else {
                _ = ImageDownloader.sharedInstance.downloadImageWithURL(url) { [weak imageCell] (result, url) in
                    if let value = result.value, imageCell?.tag == indexPath.row {
                        imageCell?.setImage(value.image)
                    }
                }
                return cell
            }
            imageCell.setImage(cache)
            return imageCell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let previewCell = cell as? ListingDeckImagePreviewCell else { return }
        previewCell.resetZoom()
    }

    func currentPreviewCell() -> ListingDeckImagePreviewCell? {
        return photoViewer.previewCellAt(photoViewer.currentPage)
    }

    // MARK: PhotoViewerVCType

    @objc func dismissView() {
        if chatView?.isFirstResponder ?? false {
            dismissChat()
        } else if !viewModel.isPlayable, let current = currentPreviewCell(), current.isZooming {
            current.resetZoom()
        } else {
            closeView()
        }
    }

    func didTapOnView() {
        guard let current = currentPreviewCell(), current.isZooming else {
            closeView()
            return
        }
        current.resetZoom(animated: true)
    }

    // MARK: Actions

    @objc func dismissChat() {
        chatView?.resignFirstResponder()
        setLeftCloseButton()
    }

    // MARK: UIGestureRecognizer

    func addEdgeGesture(_ edgeGestures: [UIGestureRecognizer]) {
        edgeGestures.forEach { view.removeGestureRecognizer($0) }
        self.edgeGestures = edgeGestures

        edgeGestures.forEach {
            view.addGestureRecognizer($0)
            $0.delegate = self
        }
    }

}

extension PhotoViewerViewController: UIGestureRecognizerDelegate {
    private func currentCellIsZooming() -> Bool {
        return currentPreviewCell()?.isZooming ?? false
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !currentCellIsZooming()
    }
}

protocol PhotoViewerViewType: class {
    func updateCurrentPage(_ current: Int)
    func updateNumberOfPages(_ pagesCount: Int)
    func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String)
}

final class ChatButton: UIControl {

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private let textFont = UIFont.systemBoldFont(size: 17)

    override var intrinsicContentSize: CGSize {

        let width = (LGLocalizedString.photoViewerChatButton as NSString)
            .size(withAttributes: [NSAttributedStringKey.font: textFont]).width
        return CGSize(width: width + 2*Metrics.margin + 44, height: 44) }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.white.cgColor
        applyShadow(withOpacity: 0.2, radius: 0, color: UIColor.black.cgColor)
        layer.shadowOffset = CGSize(width: 0, height: 2)

        let imageView = UIImageView(image: #imageLiteral(resourceName: "nit_photo_chat"))
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.isUserInteractionEnabled = false
        imageView.applyShadow(withOpacity: 0.2, radius: 0, color: UIColor.black.cgColor)
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)

        let label = UILabel()
        label.text = LGLocalizedString.photoViewerChatButton
        label.textColor = UIColor.white
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.font = textFont
        label.isUserInteractionEnabled = false
        label.applyShadow(withOpacity: 0.2, radius: 0, color: UIColor.black.cgColor)
        label.layer.shadowOffset = CGSize(width: 0, height: 2)

        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: Metrics.margin, bottom: 0, right: Metrics.margin)
        stackView.isUserInteractionEnabled = false

        addSubviewForAutoLayout(stackView)

        stackView.axis = .horizontal
        stackView.spacing = Metrics.shortMargin
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.layout(with: self).fill()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setRoundedCorners()
        let cornerRadius = min(height, width) / 2.0
        layer.shadowRadius = cornerRadius
    }
}
