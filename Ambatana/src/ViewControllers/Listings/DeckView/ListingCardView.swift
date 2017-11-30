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
import MapKit


protocol ListingCardViewDelegate {
    func didTapOnStatusView()
}

final class ListingCardView: UICollectionViewCell, UIScrollViewDelegate, PassthroughScrollViewDelegate {
    private struct Identifier {
        static let reusableID = String(describing: ListingDeckImagePreviewCell.self)
    }

    var delegate: (ListingCardDetailsViewDelegate & ListingCardViewDelegate & ListingCardDetailMapViewDelegate)? {
        didSet { detailsView.delegate = delegate }
    }

    var rxShareButton: Reactive<UIButton> { return userView.rxShareButton }
    var rxActionButton: Reactive<UIButton> { return userView.rxActionButton }

    let userView = ListingCardUserView()
    let layout = ListingDeckImagePreviewLayout()

    private let binder = ListingCardViewBinder()
    private(set) var disposeBag = DisposeBag()

    private let statusView = ProductStatusView()
    private let statusTapGesture = UITapGestureRecognizer(target: self, action: #selector(touchUpStatusView))

    private let previewImageView = UIImageView()
    private var previewImageViewHeight: NSLayoutConstraint?

    private let gradient = GradientView(colors: [UIColor.black.withAlphaComponent(0.2), UIColor.black.withAlphaComponent(0)])
    private let countImageView = UIImageView(image: #imageLiteral(resourceName: "nit_preview_count"))
    private let imageCountLabel = UILabel()

    private let verticalScrollView = PassthroughScrollView()
    private var scrollViewContentInset: UIEdgeInsets = UIEdgeInsets.zero

    private let detailsView = ListingCardDetailsView()
    private var fullMapConstraints: [NSLayoutConstraint] = []

    private var imageDownloader: ImageDownloaderType?
    private(set) var pageCount: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        binder.cardView = self
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()

        fullMapConstraints.forEach { detailsView.detailMapView.removeConstraint($0) }
        fullMapConstraints.removeAll()
        reloadData(animated: false)
    }

    func populateWith(listingViewModel: ListingCardViewCellModel, imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
        detailsView.populateWithViewModel(listingViewModel)
        binder.bind(withViewModel: listingViewModel)
    }

    func populateWith(userInfo: ListingVMUserInfo) {
        userView.populate(withUserName: userInfo.name, icon: userInfo.avatar,
                          imageDownloader: ImageDownloader.sharedInstance)
    }

    func populateWith(imagesURLs: [URL]) {
        guard let url = imagesURLs.first else { return }
        let cache = imageDownloader?.cachedImageForUrl(url)
        guard cache == nil else {
            previewImageView.image = cache
            return
        }
        _ = imageDownloader?.downloadImageWithURL(url) { [weak self] (result, url) in
            if let value = result.value {
                self?.previewImageView.image = value.image
            }
        }

        update(pageCount: imagesURLs.count)
    }

    func populateWith(status: ListingViewModelStatus, featured: Bool) {
        statusTapGesture.isEnabled = featured
        statusView.isHidden = status.string == nil
        statusView.setFeaturedStatus(status, featured: featured)
    }

    func reloadData(animated: Bool) {
        layoutVerticalContentInset(animated: animated)
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

    func showFullMap(fromRect rect: CGRect) {
        detailsView.detailMapView.showRegion(animated: true)
        fullMapConstraints = [
            detailsView.detailMapView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            detailsView.detailMapView.heightAnchor.constraint(equalToConstant: contentView.height)
        ]
        NSLayoutConstraint.activate(fullMapConstraints)

        UIView.animate(withDuration: 0.3) {
            self.detailsView.detailMapView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(1)
            self.detailsView.layoutIfNeeded()
        }
    }

    func hideFullMap() {
        fullMapConstraints.forEach { detailsView.detailMapView.removeConstraint($0) }
        fullMapConstraints.removeAll()
        UIView.animate(withDuration: 0.3) {
            self.detailsView.detailMapView.hideMap(animated: true)
            self.detailsView.detailMapView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0)
            self.detailsView.layoutIfNeeded()
        }
    }

    private func setupUI() {
        setupPreviewImageView()
        setupImagesCount()
        setupVerticalScrollView()
        setupStatusView()

        backgroundColor = .clear
        contentView.backgroundColor = .white
    }

    private func setupStatusView() {
        contentView.addSubview(statusView)
        statusView.translatesAutoresizingMaskIntoConstraints = false

        statusView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                        constant: Metrics.margin).isActive = true
        statusView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        statusView.addGestureRecognizer(statusTapGesture)
    }

    @objc private func touchUpStatusView() {
        statusView.bounce { [weak self] in
            self?.delegate?.didTapOnStatusView()
        }
    }

    private func setupPreviewImageView() {
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.clipsToBounds = true
        contentView.addSubview(previewImageView)
        previewImageView.layout(with: contentView)
            .fillHorizontal().top().proportionalHeight(multiplier: 0.7) { [weak self] in
                self?.previewImageViewHeight = $0
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
        verticalScrollView.showsVerticalScrollIndicator = false
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
        detailsView.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor,
                                            multiplier: 1.0,
                                            constant: -stickyHeight).isActive = true
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
        let topInset = previewImageView.height
        let top = topInset - userView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height

        guard scrollViewContentInset.top != top else { return }

        scrollViewContentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        verticalScrollView.contentInset = scrollViewContentInset
        verticalScrollView.setContentOffset(CGPoint(x: 0, y: -scrollViewContentInset.top), animated: animated)
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -0.5 {
            scrollView.contentOffset.y = -0.5
        } else if scrollView.contentOffset.y < -scrollViewContentInset.top {
            self.previewImageViewHeight?.constant = abs(scrollViewContentInset.top + scrollView.contentOffset.y)
        } else if abs(scrollView.contentOffset.y / scrollViewContentInset.top) < 0.5 {
            let ratio = abs(scrollView.contentOffset.y / scrollViewContentInset.top) / 0.5
            updateCount(alpha: ratio)
            updateBlur(alpha: 1 - ratio)
        } else {
            updateCount(alpha: 1.0)
            updateBlur(alpha: 0)
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

    // MARK: PassthroughScrollViewDelegate

    func viewToReceiveTouch(scrollView: PassthroughScrollView) -> UIView {
        let contentOffset = scrollView.contentOffset.y

        if contentOffset >= 0 {
            return detailsView
        }
        return previewImageView
    }

    func shouldTouchPassthroughScrollView(scrollView: PassthroughScrollView,
                                          point: CGPoint, with event: UIEvent?) -> Bool {
        return scrollView.contentOffset.y >= 0
    }
}
