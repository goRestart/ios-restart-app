//
//  ListingCardView.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

typealias ListingCardViewCellModel = ListingCarouselCellModel
// TODO: ABIOS-3101 https://ambatana.atlassian.net/browse/ABIOS-3101
final class ListingCardView: UICollectionViewCell, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, PassthroughScrollViewDelegate {
    private struct Identifier {
        static let reusableID = String(describing: ListingDeckImagePreviewCell.self)
    }
    private let binder = ListingCardViewBinder()
    private(set) var disposeBag = DisposeBag()

    var rxShareButton: Reactive<UIButton> { return userView.rxShareButton }
    var rxActionButton: Reactive<UIButton> { return userView.rxActionButton }
    let userView = ListingCardUserView()
    let layout = ListingDeckImagePreviewLayout()

    private let previewCollectionView: UICollectionView
    private var collectionHeight: NSLayoutConstraint?
    private var urls: [URL] = []

    private let gradient = GradientView(colors: [UIColor.black.withAlphaComponent(0.2), UIColor.black.withAlphaComponent(0)])
    private let countImageView = UIImageView(image: #imageLiteral(resourceName: "nit_preview_count"))
    private let imageCountLabel = UILabel()

    private let verticalScrollView = PassthroughScrollView()
    private var scrollViewContentInset: UIEdgeInsets = UIEdgeInsets.zero

    private let detailsView = ListingCardDetailsView()

    private var imageDownloader: ImageDownloaderType?

    private var pageCount: Int { get { return urls.count } }

    override init(frame: CGRect) {
        previewCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        super.init(frame: frame)
        binder.cardView = self
        binder.bind()

        previewCollectionView.register(ListingDeckImagePreviewCell.self,
                                       forCellWithReuseIdentifier: Identifier.reusableID)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()

        urls.removeAll()
        reloadData(animated: false)
    }

    func populateWith(cellViewModel viewModel: ListingCardViewModel,
                      listingViewModel: ListingViewModel,
                      imageDownloader: ImageDownloaderType) {
        populateImageViewsWith(cellViewModel: viewModel, imageDownloader: imageDownloader)
        populateImageCount(cellViewModel: viewModel)
        populateUserInfo(cellViewModel: viewModel, imageDownloader: imageDownloader)

        binder.bind(withViewModel: listingViewModel)
    }
    private func populateUserInfo(cellViewModel viewModel: ListingCardViewModel,
                                  imageDownloader: ImageDownloaderType) {
        let name = viewModel.userName
        let url = viewModel.avatar
        userView.populate(withUserName: name ?? "Facundo Menzella",
                                    icon: url,
                                    imageDownloader: imageDownloader, isMine: viewModel.isMine)
    }

    private func populateImageCount(cellViewModel viewModel: ListingCardViewModel) {
        update(pageCount: viewModel.images.count)
    }

    private func populateImageViewsWith(cellViewModel viewModel: ListingCardViewModel,
                                        imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
        self.urls = viewModel.images
        update(pageCount: urls.count)
        
        previewCollectionView.delegate = self
        previewCollectionView.dataSource = self
        previewCollectionView.isPagingEnabled = true
        previewCollectionView.reloadData()
    }

    func reloadData(animated: Bool) {
        layoutVerticalContentInset(animated: animated)

        previewCollectionView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(pageCount: Int) {
        if pageCount > 1 {
            imageCountLabel.text = "1/\(pageCount)"
        } else {
            imageCountLabel.text = "1"
        }
    }

    func update(currentPage: Int) {
        imageCountLabel.text = "\(currentPage)/\(urls.count)"
    }

    private func setupUI() {
        setupCollectionView()
        setupImagesCount()
        setupVerticalScrollView()

        backgroundColor = .clear
        contentView.backgroundColor = .white
    }

    private func setupCollectionView() {
        previewCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(previewCollectionView)
        previewCollectionView.layout(with: contentView)
            .fillHorizontal().top().proportionalHeight(multiplier: 0.8) { [weak self] in
            self?.collectionHeight = $0
        }
    }

    private func setupImagesCount() {
        gradient.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gradient)
        gradient.topAnchor.constraint(lessThanOrEqualTo: contentView.topAnchor).isActive = true
        gradient.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        gradient.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true

        countImageView.contentMode = .center
        countImageView.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)

        gradient.addSubview(countImageView)
        gradient.addSubview(imageCountLabel)

        countImageView.translatesAutoresizingMaskIntoConstraints = false
        countImageView.layout().widthProportionalToHeight().width(32)
        countImageView.layout(with: gradient).leading(by: Metrics.margin)
        countImageView.layout(with: imageCountLabel).centerY()

        imageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        imageCountLabel.layout(with: countImageView)
            .leading(to: .trailing,
                     by: 0,
                     multiplier: 1.0,
                     relatedBy: .equal,
                     priority: UILayoutPriorityRequired,
                     constraintBlock: nil)

        imageCountLabel.layout(with: gradient).top(by: Metrics.margin).trailing().bottom()
        imageCountLabel.textColor = .white
        imageCountLabel.font = UIFont.mediumButtonFont
    }

    private func setupVerticalScrollView() {
        verticalScrollView.delegate = self
        verticalScrollView.touchDelegate = self
        verticalScrollView.translatesAutoresizingMaskIntoConstraints = false
        verticalScrollView.contentInset = UIEdgeInsets(top: 128, left: 0, bottom: 0, right: 0)
        contentView.addSubview(verticalScrollView)
        verticalScrollView.layout(with: contentView).leading().trailing().bottom().top()
        verticalScrollView.backgroundColor = .clear

        userView.translatesAutoresizingMaskIntoConstraints = false
        verticalScrollView.addSubview(userView)
        userView.topAnchor.constraint(greaterThanOrEqualTo: gradient.bottomAnchor).isActive = true
        userView.layout(with: verticalScrollView).fillHorizontal().top().centerX().leading().trailing()
        userView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.12).isActive = true

        detailsView.backgroundColor = .white
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        verticalScrollView.addSubview(detailsView)

        detailsView.layout(with: userView).fillHorizontal().below()
        detailsView.layout(with: verticalScrollView).fillHorizontal().bottom().centerX()
        let stickyHeight = userView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        detailsView.layout(with: verticalScrollView).proportionalWidth().proportionalHeight(add: -stickyHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.setRoundedCorners([.allCorners], cornerRadius: 8.0)
        applyShadow(withOpacity: 0.3, radius: 16.0, color: #colorLiteral(red: 0.7803921569, green: 0.8078431373, blue: 0.7803921569, alpha: 1).cgColor)
        layer.shadowOffset = CGSize(width: 0, height: 0.5)

        layoutVerticalContentInset(animated: false)
        layout.invalidateLayout()
    }

    private func layoutVerticalContentInset(animated: Bool) {
        let topInset = previewCollectionView.height
        let top = topInset - userView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        scrollViewContentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        verticalScrollView.contentInset = scrollViewContentInset
        verticalScrollView.setContentOffset(CGPoint(x: 0, y: -scrollViewContentInset.top), animated: animated)
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == previewCollectionView {
            binder.update(scrollViewBindings: scrollView)
        } else {
            if scrollView.contentOffset.y > -0.5 {
                scrollView.contentOffset.y = -0.5
            } else if scrollView.contentOffset.y < -scrollViewContentInset.top {
                self.collectionHeight?.constant = abs(scrollViewContentInset.top + scrollView.contentOffset.y)
            } else if abs(scrollView.contentOffset.y / scrollViewContentInset.top) < 0.5 {
                let ratio = abs(scrollView.contentOffset.y / scrollViewContentInset.top) / 0.5
                updateCount(alpha: ratio)
                updateBlur(alpha: 1 - ratio)
            } else {
                updateCount(alpha: 1.0)
                updateBlur(alpha: 0)
            }
        }
    }

    private func updateBlur(alpha: CGFloat) {
        userView.effectView.alpha = alpha
    }

    private func updateCount(alpha: CGFloat) {
        countImageView.alpha = alpha
        imageCountLabel.alpha = alpha
        gradient.alpha = alpha
    }

    // MARK: UICollectionViewDataSource, UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.reusableID,
                                                          for: indexPath)
            guard let imageCell = cell as? ListingDeckImagePreviewCell else { return UICollectionViewCell() }
            guard indexPath.row < urls.count else { return imageCell }
            let imageURL = urls[indexPath.row]

            let cellTag = tagCellForDownloadMissmatch(imageCell, atIndexPath: indexPath)

            if imageCell.imageURL != imageURL { //Avoid reloading same image in the cell
                imageCell.imageView.image = nil

                _ = imageDownloader?.downloadImageWithURL(imageURL) { [weak imageCell] (result, url) in
                    if let value = result.value, cell.tag == cellTag {
                        imageCell?.imageURL = imageURL
                        imageCell?.imageView.image = value.image
                    }
                }
            }

            return imageCell
    }

    private func tagCellForDownloadMissmatch(_ cell: ListingDeckImagePreviewCell, atIndexPath indexPath: IndexPath) -> Int {
        let imageCellTag = (indexPath as NSIndexPath).hash
        cell.tag = imageCellTag
        cell.position = indexPath.row
        return imageCellTag
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageCell = cell as? ListingCarouselImageCell else { return }
        imageCell.resetZoom()
    }

    // MARK: PassthroughScrollViewDelegate

    func viewToReceiveTouch(scrollView: PassthroughScrollView) -> UIView {
        let contentOffset = scrollView.contentOffset.y

        if contentOffset >= 0 {
            return detailsView
        }
        return previewCollectionView
    }
    
    func shouldTouchPassthroughScrollView(scrollView: PassthroughScrollView,
                                          point: CGPoint, with event: UIEvent?) -> Bool {
        func shouldScrollHorizontally(scrollView: PassthroughScrollView,
                                         point: CGPoint, with event: UIEvent?) -> Bool {
            let contentOffset = scrollView.contentOffset.y

            let alreadyScrolledVertically = contentOffset > -scrollViewContentInset.top

            let previewPoint = previewCollectionView.convert(point, from: scrollView)
            let headerPoint = userView.convert(point, to: scrollView)
            return previewCollectionView.hitTest(previewPoint, with: event) != nil
                && userView.hitTest(headerPoint, with: event) == nil && !alreadyScrolledVertically
        }


        if shouldScrollHorizontally(scrollView: scrollView, point: point, with: event) {
            return true
        }

        return scrollView.contentOffset.y >= 0
    }
}
