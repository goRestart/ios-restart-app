//
//  PhotoViewerViewController.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

final class PhotoViewerViewController: KeyboardViewController, PhotoViewerVCType, UICollectionViewDataSource, UICollectionViewDelegate {
    private struct Identifiers { static let reusableID = ListingDeckImagePreviewCell.reusableID }

    override var prefersStatusBarHidden: Bool { return true }
    let chatView: QuickChatView
    let photoViewer = PhotoViewerView()
    private let viewModel: PhotoViewerViewModel
    private let binder = PhotoViewerViewControllerBinder()
    private var tap: UITapGestureRecognizer?

    private var edgeGesture: UIScreenEdgePanGestureRecognizer?

    init(viewModel: PhotoViewerViewModel, quickChatViewModel: QuickChatViewModel) {
        self.viewModel = viewModel
        self.chatView = QuickChatView(chatViewModel: quickChatViewModel)
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { self.view = photoViewer }

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        photoViewer.register(ListingDeckImagePreviewCell.self, forCellWithReuseIdentifier: Identifiers.reusableID)
        photoViewer.dataSource = self
        photoViewer.updateNumberOfPages(viewModel.itemsCount)

        binder.viewController = self
        binder.bind(toView: photoViewer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        setStatusBarHidden(true)
    }
    
    // MARK: NavBar

    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear

        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_carousel"),
                                         style: .plain,
                                         target: self, action: #selector(dismissChat))
        self.navigationItem.leftBarButtonItem  = leftButton

        setNavigationBarRightButtons([])
    }

    private func updateCurrentPage(_ currentPage: Int) {
        photoViewer.updateCurrentPage(currentPage)

    }

    func updateWith(keyboardChange: KeyboardChange) {
        let height = photoViewer.bounds.height - keyboardChange.origin
        chatView.updateWith(bottomInset: height,
                            animationTime: TimeInterval(keyboardChange.animationTime),
                            animationOptions: keyboardChange.animationOptions)
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
        chatView.frame = photoViewer.frame
        chatView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatView)
        chatView.layout(with: photoViewer).fill()

        view.setNeedsLayout()
        view.layoutIfNeeded()

        chatView.becomeFirstResponder()
    }

    func closeView() {
        self.presentingViewController?.dismiss(animated: true)
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.reusableID, for: indexPath)
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
        viewModel.dismiss()
    }

    func addEdgeGesture(_ edgeGesture: UIScreenEdgePanGestureRecognizer) {
        if let gesture = self.edgeGesture {
            view.removeGestureRecognizer(gesture)
        }
        view.addGestureRecognizer(edgeGesture)
    }
}
