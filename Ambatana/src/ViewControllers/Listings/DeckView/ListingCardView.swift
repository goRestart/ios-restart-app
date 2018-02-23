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
    func didTapOnPreview()
}

final class ListingCardView: UICollectionViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate, ReusableCell {
    private struct Layout {
        struct Height {
            static let previewFactor: CGFloat = 0.7
            static let userView: CGFloat = 52.0
            static let whiteGradient: CGFloat = 40.0
        }
    }

    var delegate: (ListingCardDetailsViewDelegate & ListingCardViewDelegate & ListingCardDetailMapViewDelegate)? {
        didSet { detailsView.delegate = delegate }
    }

    let userView = ListingCardUserView()

    private let binder = ListingCardViewBinder()
    private(set) var disposeBag = DisposeBag()

    private let statusView = ProductStatusView()
    private var statusTapGesture: UITapGestureRecognizer?

    private let previewImageView = UIImageView()
    var previewImageViewFrame: CGRect { return previewImageView.frame }
    private var previewImageViewHeight: NSLayoutConstraint?

    private let gradient = GradientView(colors: [UIColor.black.withAlphaComponent(0.2), UIColor.black.withAlphaComponent(0)])
    private let countImageView = UIImageView(image: #imageLiteral(resourceName: "nit_preview_count"))
    private let imageCountLabel = UILabel()

    private let whiteGradient = GradientView(colors: [UIColor.white.withAlphaComponent(0),
                                                      UIColor.white.withAlphaComponent(0.9)])

    private let scrollView = UIScrollView()
    private var scrollViewTapGesture: UITapGestureRecognizer?

    private var scrollViewContentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)

    private let detailsView = ListingCardDetailsView()
    private var detailsThreshold: CGFloat { return 0.5 * previewImageView.height }
    var isImageVisibleEnough: Bool { return abs(scrollView.contentOffset.y) > detailsThreshold }
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

        deactivateFullMap()
        previewImageView.image = nil
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
        update(pageCount: imagesURLs.count)
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
        statusTapGesture?.isEnabled = featured
        statusView.isHidden = status.string == nil
        statusView.setFeaturedStatus(status, featured: featured)
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
        contentView.bringSubview(toFront: detailsView.detailMapView)
        fullMapConstraints = [
            detailsView.detailMapView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            detailsView.detailMapView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1.0)
        ]
        NSLayoutConstraint.activate(fullMapConstraints)

        detailsView.detailMapView.showRegion(animated: true)
        UIView.animate(withDuration: 0.3) {
            self.detailsView.detailMapView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(1)
            self.detailsView.layoutIfNeeded()
        }
    }

    func hideFullMap() {
        self.detailsView.detailMapView.hideMap(animated: true)
        deactivateFullMap()
        UIView.animate(withDuration: 0.3) {
            self.detailsView.detailMapView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0)
            self.detailsView.layoutIfNeeded()
        }
    }

    private func deactivateFullMap() {
        fullMapConstraints.forEach {
            contentView.removeConstraint($0)
            detailsView.detailMapView.removeConstraint($0)
        }
    }

    private func setupUI() {
        setupPreviewImageView()
        setupImagesCount()
        setupVerticalScrollView()
        setupStatusView()
        setupWhiteGradient()

        backgroundColor = .clear
        contentView.backgroundColor = .white


    }

    private func setupWhiteGradient() {
        whiteGradient.translatesAutoresizingMaskIntoConstraints = false
        whiteGradient.clipsToBounds = true
        contentView.addSubview(whiteGradient)
        NSLayoutConstraint.activate([
            whiteGradient.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            whiteGradient.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            whiteGradient.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            whiteGradient.heightAnchor.constraint(equalToConstant: Layout.Height.whiteGradient)
        ])
    }

    private func setupStatusView() {
        contentView.addSubview(statusView)
        statusView.translatesAutoresizingMaskIntoConstraints = false

        statusView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                        constant: Metrics.margin).isActive = true
        statusView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        let statusTap = UITapGestureRecognizer(target: self, action: #selector(touchUpStatusView))
        statusView.addGestureRecognizer(statusTap)
        statusTapGesture = statusTap
    }

    @objc private func touchUpStatusView() {
        statusView.bounce { [weak self] in
            self?.delegate?.didTapOnStatusView()
        }
    }

    private func setupPreviewImageView() {
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.clipsToBounds = true
        previewImageView.contentMode = .scaleAspectFill
        contentView.addSubview(previewImageView)
        previewImageView.layout(with: contentView).fillHorizontal().top()
        previewImageViewHeight = previewImageView.heightAnchor.constraint(equalTo: previewImageView.widthAnchor,
                                                                          multiplier: 1.1,
                                                                          constant: 0)
        previewImageViewHeight?.isActive = true
    }

    private func setupImagesCount() {
        gradient.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gradient)
        let gradientTop = gradient.topAnchor.constraint(equalTo: contentView.topAnchor)
        gradientTop.isActive = true
        gradientTop.priority = .required - 1

        gradient.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        gradient.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        gradient.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4)

        countImageView.contentMode = .center
        countImageView.setContentHuggingPriority(.required, for: .horizontal)

        gradient.addSubview(countImageView)
        gradient.addSubview(imageCountLabel)

        countImageView.translatesAutoresizingMaskIntoConstraints = false
        countImageView.layout().widthProportionalToHeight().width(32)
        countImageView.layout(with: gradient)
            .leading(by: Metrics.shortMargin).top(relatedBy: .greaterThanOrEqual).bottom(relatedBy: .lessThanOrEqual)

        imageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        imageCountLabel.layout(with: countImageView).leading(to: .trailing)

        imageCountLabel.layout(with: gradient).top(by: Metrics.shortMargin).trailing().bottom()
        imageCountLabel.textColor = .white
        imageCountLabel.font = UIFont.mediumButtonFont

        countImageView.layout(with: imageCountLabel).centerY()
    }

    private func setupVerticalScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = UIEdgeInsets(top: 256, left: 0, bottom: 0, right: 0)
        contentView.addSubview(scrollView)
        scrollView.layout(with: contentView).leading().trailing().bottom().top()
        scrollView.backgroundColor = .clear

        userView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(userView)
        userView.topAnchor.constraint(greaterThanOrEqualTo: gradient.bottomAnchor).isActive = true
        userView.layout(with: scrollView).fillHorizontal().top().centerX().leading().trailing()
        userView.heightAnchor.constraint(equalToConstant: Layout.Height.userView).isActive = true

        detailsView.backgroundColor = .white
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        detailsView.isUserInteractionEnabled = false
        scrollView.addSubview(detailsView)

        detailsView.layout(with: userView).fillHorizontal().below()
        detailsView.layout(with: scrollView).bottom().centerX()

        let scrollTap = UITapGestureRecognizer(target: self, action: #selector(didTapOnScrollView))
        scrollTap.delegate = self
        scrollView.addGestureRecognizer(scrollTap)
        scrollViewTapGesture = scrollTap
    }

    func layoutVerticalContentInset(animated: Bool) {
        let target = (contentView.bounds.height * Layout.Height.previewFactor) - Layout.Height.userView

        guard scrollViewContentInset.top != target else { return }
        scrollViewContentInset = UIEdgeInsets(top: target, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = scrollViewContentInset
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollViewContentInset.top), animated: animated)
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        contentView.setRoundedCorners([.allCorners], cornerRadius: Metrics.margin)
        applyShadow(withOpacity: 0.3, radius: Metrics.margin, color: #colorLiteral(red: 0.7803921569, green: 0.8078431373, blue: 0.7803921569, alpha: 1).cgColor)
        layer.shadowOffset = CGSize(width: 0, height: 0.5)
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            scrollView.contentOffset.y = CGFloat(0 - Float.ulpOfOne)
        } else if scrollView.contentOffset.y < -scrollViewContentInset.top {
            previewImageViewHeight?.constant = abs(scrollViewContentInset.top + scrollView.contentOffset.y)
        } else if abs(scrollView.contentOffset.y / scrollViewContentInset.top) < 0.7 {
            let ratio = abs(scrollView.contentOffset.y / scrollViewContentInset.top) / 0.7
            updateCount(alpha: ratio)
            updateBlur(alpha: 1 - ratio)
        } else {
            updateCount(alpha: 1.0)
            updateBlur(alpha: 0)
        }
        detailsView.isUserInteractionEnabled = abs(scrollView.contentOffset.y) < detailsThreshold
    }

    private func updateBlur(alpha: CGFloat) {
        userView.effectView.alpha = alpha
        whiteGradient.alpha = min(0.9, 1 - alpha)
    }

    private func updateCount(alpha: CGFloat) {
        countImageView.alpha = alpha
        imageCountLabel.alpha = alpha
        gradient.alpha = alpha
    }

    private func showFullImagePreview() {
        detailsView.isUserInteractionEnabled = false
        let offsetY = -scrollViewContentInset.top
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn, animations: { [weak self] in
                        self?.scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
            }, completion: nil)
    }

    // MARK: UITapGestureRecognizer

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !detailsView.isMapExpanded
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == statusTapGesture && otherGestureRecognizer == scrollViewTapGesture
    }

    @objc private func didTapOnScrollView(sender: UITapGestureRecognizer) {
        guard !detailsView.isMapExpanded else {
            detailsView.detailMapView.hideMap(animated: true)
            return
        }

        let didTapBelowUser = sender.location(in: userView).y > 0
        if didTapBelowUser && isImageVisibleEnough {
            scrollToDetail()
        } else if isImageVisibleEnough {
            delegate?.didTapOnPreview()
        } else {
            showFullImagePreview()
        }
    }

    private func scrollToDetail() {
        detailsView.isUserInteractionEnabled = true
        let offsetY = max(contentView.height - detailsView.bounds.height - userView.bounds.height, 0)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn, animations: { [weak self] in
                        self?.scrollView.setContentOffset(CGPoint(x: 0, y: -offsetY), animated: true)
            }, completion: nil)
    }

    func onboardingFlashDetails() {
        let currentOffset = scrollView.contentOffset
        let flashOffset = CGPoint(x: 0, y: currentOffset.y + 10)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.scrollView.setContentOffset(flashOffset, animated: true)
        })
        delay(0.2) {
            self.scrollView.setContentOffset(currentOffset, animated: true)
        }
    }
}

extension ListingCardView: ListingDeckViewControllerBinderCellType {
    var rxShareButton: Reactive<UIButton> { return userView.rxShareButton }
    var rxActionButton: Reactive<UIButton> { return userView.rxActionButton }
    var rxUserIcon: Reactive<UIButton> { return userView.rxUserIcon }
}

