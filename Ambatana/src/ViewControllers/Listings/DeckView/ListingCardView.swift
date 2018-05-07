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
import LGCoreKit

protocol ListingCardViewDelegate: class {
    func cardViewDidTapOnStatusView(_ cardView: ListingCardView)
    func cardViewDidTapOnPreview(_ cardView: ListingCardView)
    func cardViewDidShowMoreInfo(_ cardView: ListingCardView)
    func cardViewDidScroll(_ cardView: ListingCardView, contentOffset: CGFloat)
}

final class ListingCardView: UICollectionViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate, ReusableCell {
    private struct Layout {
        struct Height {
            static let userView: CGFloat = 64.0
        }
        static let stickyHeaderThreadshold = Layout.Height.userView
    }

    var delegate: (ListingCardDetailsViewDelegate & ListingCardViewDelegate & ListingCardDetailMapViewDelegate)? {
        didSet { detailsView.delegate = delegate }
    }

    let userView: ListingCardUserView = {
        let userView = ListingCardUserView()
        userView.clipsToBounds = true
        return userView
    }()

    private let binder = ListingCardViewBinder()
    private(set) var disposeBag = DisposeBag()

    private let statusView = ProductStatusView()
    private var statusTapGesture: UITapGestureRecognizer?

    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        return imageView
    }()
    private var previewHeight: NSLayoutConstraint?

    var previewVisibleFrame: CGRect {
        let size = CGSize(width: contentView.width, height: previewImageView.height)
        return CGRect(origin: frame.origin, size: size)
    }
    private let gradient = GradientView(colors: [UIColor.black.withAlphaComponent(0.2), .clear])
    private let countImageView = UIImageView(image: #imageLiteral(resourceName: "nit_preview_count"))
    private let imageCountLabel = UILabel()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .white
        return scrollView
    }()
    private var fullDetailsOffset: CGFloat { return previewImageView.bounds.height }
    private var lastMoreInfoState: MoreInfoState = MoreInfoState.hidden {
        didSet { moreInfoStateDidChange(oldValue, current: lastMoreInfoState) }
    }

    private var detailsViewFullyVisible: Bool { return scrollView.contentOffset.y - fullDetailsOffset >= -CGFloat.ulpOfOne }
    private let detailsView = ListingCardDetailsView()
    private var isPreviewVisible: Bool { return scrollView.contentOffset.y == 0 }

    private var imageDownloader: ImageDownloaderType?
    private(set) var pageCount: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        binder.cardView = self
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        recycleDisposeBag()
        userView.prepareForReuse()
        previewImageView.image = nil
        userView.alpha = 0
        lastMoreInfoState = .hidden
    }

    func populateWith(cellModel listingViewModel: ListingCardViewCellModel, imageDownloader: ImageDownloaderType) {
        userView.tag = self.tag
        self.imageDownloader = imageDownloader
        binder.bind(withViewModel: listingViewModel)
        populateWith(details: listingViewModel)
    }

    func populateWith(_ listingSnapshot: ListingDeckSnapshotType, imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
        populateWith(preview: listingSnapshot.preview, imageCount: listingSnapshot.imageCount)
        populateWith(userInfo: listingSnapshot.userInfo)
        let action = listingSnapshot.isMine ? ListingCardUserView.Action.edit
                                            : ListingCardUserView.Action.favourite(isOn: listingSnapshot.isFavorite)
        userView.set(action: action)
        detailsView.populateWith(productInfo: listingSnapshot.productInfo, showExactLocationOnMap: false)
        detailsView.populateWith(listingStats: nil, postedDate: nil)
    }

    func populateWith(details listingViewModel: ListingCardViewCellModel) {
        detailsView.populateWithViewModel(listingViewModel)
    }

    func populateWith(userInfo: ListingVMUserInfo?) {
        guard let info = userInfo else { return }
        userView.populate(withUserName: info.name,
                          placeholder: info.avatarPlaceholder(),
                          icon: info.avatar,
                          imageDownloader: ImageDownloader.sharedInstance,
                          badgeType: userInfo?.badge ?? .noBadge)
        UIView.animate(withDuration: 0.1) { self.userView.alpha = 1 }
    }

    func populateWith(preview: URL?, imageCount: Int) {
        update(pageCount: imageCount)
        guard let previewURL = preview else { return }
        _ = imageDownloader?.downloadImageWithURL(previewURL) { [weak self] (result, url) in
            if let value = result.value {
                DispatchQueue.main.async {
                    self?.previewImageView.image = value.image
                    self?.updateImage(withRatio: value.image.size.height / value.image.size.width)
                    self?.previewImageView.setNeedsDisplay()
                }
            }
        }
    }

    private func updateImage(withRatio ratio: CGFloat) {
        if let heightConstraint = previewHeight {
            previewImageView.removeConstraint(heightConstraint)
        }
        let height = previewImageView.heightAnchor.constraint(equalTo: previewImageView.widthAnchor, multiplier: ratio)
        height.isActive = true
        previewHeight = height
        setNeedsLayout()
    }

    func populateWith(status: ListingViewModelStatus?, featured: Bool) {
        guard let listingStatus = status else {
            statusView.isHidden = true
            return
        }
        statusTapGesture?.isEnabled = featured
        let statusVisible = featured || listingStatus.shouldShowStatus
        statusView.isHidden = !statusVisible
        statusView.setFeaturedStatus(listingStatus, featured: featured)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(pageCount: Int) {
        self.pageCount = pageCount
        if pageCount > 1 {
            imageCountLabel.text = "1/\(pageCount)"
        } else {
            imageCountLabel.text = "1"
        }
    }

    private func setupUI() {
        let userViewGradient = GradientView(colors: [.clear, UIColor.black.withAlphaComponent(0.2)])

        contentView.addSubviewsForAutoLayout([scrollView, gradient, statusView, userView])
        previewImageView.addSubviewForAutoLayout(userViewGradient)
        scrollView.addSubviewsForAutoLayout([previewImageView, detailsView])
        gradient.addSubviewsForAutoLayout([countImageView, imageCountLabel])

        NSLayoutConstraint.activate([
            userViewGradient.leftAnchor.constraint(equalTo: previewImageView.leftAnchor),
            userViewGradient.rightAnchor.constraint(equalTo: previewImageView.rightAnchor),
            userViewGradient.bottomAnchor.constraint(equalTo: previewImageView.topAnchor),
            userViewGradient.heightAnchor.constraint(equalTo: userView.heightAnchor, constant: 2)
        ])
        setupVerticalScrollView()
        setupPreviewImageView()

        setupImagesCount()
        setupStatusView()
        setupDetails()

        backgroundColor = .clear
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
    }

    private func setupStatusView() {
        statusView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                        constant: Metrics.margin).isActive = true
        statusView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        let statusTap = UITapGestureRecognizer(target: self, action: #selector(touchUpStatusView))
        statusView.addGestureRecognizer(statusTap)
        statusTapGesture = statusTap
        statusView.isHidden = true
    }

    @objc private func touchUpStatusView() {
        statusView.bounce { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.cardViewDidTapOnStatusView(strongSelf)
        }
    }

    private func setupPreviewImageView() {
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            previewImageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            previewImageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            previewImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
    }

    private func setupImagesCount() {
        let gradientTop = gradient.topAnchor.constraint(equalTo: contentView.topAnchor)
        gradientTop.isActive = true
        gradientTop.priority = .required - 1

        NSLayoutConstraint.activate([
            gradient.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradient.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            gradient.heightAnchor.constraint(equalTo: userView.heightAnchor),

            countImageView.widthAnchor.constraint(equalToConstant: 32),
            countImageView.heightAnchor.constraint(lessThanOrEqualTo: countImageView.widthAnchor),
            countImageView.leftAnchor.constraint(equalTo: gradient.leftAnchor, constant: Metrics.margin),
            countImageView.topAnchor.constraint(greaterThanOrEqualTo: gradient.topAnchor),
            countImageView.bottomAnchor.constraint(lessThanOrEqualTo: gradient.bottomAnchor),

            imageCountLabel.leftAnchor.constraint(equalTo: countImageView.rightAnchor),
            imageCountLabel.topAnchor.constraint(equalTo: gradient.topAnchor, constant: Metrics.margin),
            imageCountLabel.rightAnchor.constraint(equalTo: gradient.rightAnchor),
            imageCountLabel.topAnchor.constraint(equalTo: gradient.bottomAnchor),

            countImageView.centerYAnchor.constraint(equalTo: imageCountLabel.centerYAnchor)
        ])
        countImageView.contentMode = .center
        countImageView.setContentHuggingPriority(.required, for: .horizontal)

        imageCountLabel.textColor = .white
        imageCountLabel.font = UIFont.mediumButtonFont
    }

    private func setupVerticalScrollView() {
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ])
    }

    private func setupDetails() {
        detailsView.backgroundColor = .white
        detailsView.isUserInteractionEnabled = false

        let scrollTap = UITapGestureRecognizer(target: self, action: #selector(didTapOnScrollView))
        contentView.addGestureRecognizer(scrollTap)

        NSLayoutConstraint.activate([
            userView.topAnchor.constraint(greaterThanOrEqualTo: gradient.bottomAnchor),
            userView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            detailsView.topAnchor.constraint(equalTo: userView.bottomAnchor),

            userView.heightAnchor.constraint(equalToConstant: Layout.Height.userView),
            detailsView.topAnchor.constraint(equalTo: previewImageView.bottomAnchor),
            detailsView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            detailsView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            detailsView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            detailsView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        contentView.layer.cornerRadius = Metrics.margin
        previewImageView.layer.cornerRadius = Metrics.margin
    }

    func update(bottomContentInset inset: CGFloat) {
        scrollView.contentOffset = .zero
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inset, right: 0)
    }

    // MARK: UIScrollViewDelegate

    private func moreInfoStateDidChange(_ previous: MoreInfoState, current: MoreInfoState) {
        guard previous != current, current == .shown else { return }
        delegate?.cardViewDidShowMoreInfo(self)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            let scaleFactor = 1 + (-5*scrollView.contentOffset.y / contentView.bounds.height) // multiplied by 5 to avoid seeing the bottom of the card
            previewImageView.transform = CGAffineTransform.identity
                .translatedBy(x: 0, y: scrollView.contentOffset.y)
                .scaledBy(x: scaleFactor, y: scaleFactor)
        } else {
            previewImageView.transform = CGAffineTransform.identity
        }
        previewImageView.setNeedsDisplay()
        lastMoreInfoState = detailsViewFullyVisible ? .shown : .hidden
        detailsView.isUserInteractionEnabled = !isPreviewVisible

        delegate?.cardViewDidScroll(self, contentOffset: scrollView.contentOffset.y + scrollView.contentInset.top  )
    }

    private func updateCount(alpha: CGFloat) {
        countImageView.alpha = alpha
        imageCountLabel.alpha = alpha
        gradient.alpha = alpha
    }

    private func showFullImagePreview() {
        detailsView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn, animations: { [weak self] in
                        self?.scrollView.setContentOffset(.zero, animated: true)
            }, completion: nil)
    }

    // MARK: UITapGestureRecognizer

    @objc private func didTapOnScrollView(sender: UITapGestureRecognizer) {
        let didTapBelowUser = sender.location(in: userView).y > 0
        if didTapBelowUser && isPreviewVisible {
            scrollToDetail()
        } else if isPreviewVisible {
            delegate?.cardViewDidTapOnPreview(self)
        } else {
            showFullImagePreview()
        }
    }

    private func scrollToDetail() {
        detailsView.isUserInteractionEnabled = true
        let detailsOffset = previewImageView.height - contentView.height + detailsView.height
        let y = min(previewImageView.height, detailsOffset)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn, animations: { [weak self] in
                        self?.scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
            }, completion: nil)
    }
}

extension ListingCardView: ListingDeckViewControllerBinderCellType {
    var rxShareButton: Reactive<UIButton> { return userView.rxShareButton }
    var rxActionButton: Reactive<UIButton> { return userView.rxActionButton }
    var rxUserIcon: Reactive<UIButton> { return userView.rxUserIcon }

    func recycleDisposeBag() {
        disposeBag = DisposeBag()
    }
}

