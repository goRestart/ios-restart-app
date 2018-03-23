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
    func didShowMoreInfo()
}

final class ListingCardView: UICollectionViewCell, UIScrollViewDelegate, UIGestureRecognizerDelegate, ReusableCell {
    private struct Layout {
        struct Height {
            static let userView: CGFloat = 64.0
            static let whiteGradient: CGFloat = 0.7 * DeviceFamily.insetCorrection
            static let topInset: CGFloat = 350 // completly random
        }
        static let stickyHeaderThreadshold = Layout.Height.userView
    }

    var delegate: (ListingCardDetailsViewDelegate & ListingCardViewDelegate & ListingCardDetailMapViewDelegate)? {
        didSet { detailsView.delegate = delegate }
    }
    var defaultContentInset: UIEdgeInsets = UIEdgeInsets(top: Layout.Height.topInset, left: 0, bottom: 0, right: 0)
    private var verticalInset: CGFloat = 0

    let userView = ListingCardUserView()
    private var userViewTopConstraints: [NSLayoutConstraint] = []
    private var userViewScrollingConstraints: [NSLayoutConstraint] = []

    private let binder = ListingCardViewBinder()
    private(set) var disposeBag = DisposeBag()

    private let statusView = ProductStatusView()
    private var statusTapGesture: UITapGestureRecognizer?

    private let previewImageView = UIImageView()
    var previewVisibleFrame: CGRect {
        let size = CGSize(width: contentView.width, height: previewImageView.height)
        return CGRect(origin: frame.origin, size: size)
    }
    private let gradient = GradientView(colors: [UIColor.black.withAlphaComponent(0.2), UIColor.black.withAlphaComponent(0)])
    private let countImageView = UIImageView(image: #imageLiteral(resourceName: "nit_preview_count"))
    private let imageCountLabel = UILabel()

    private let whiteGradient = GradientView(colors: [UIColor.white.withAlphaComponent(0),
                                                      UIColor.white.withAlphaComponent(0.9)])
    private let bottomBackground = UIView()
    private var bottomBackgroundHeight: NSLayoutConstraint?
    private let scrollView = UIScrollView()
    private var scrollViewTapGesture: UITapGestureRecognizer?

    private let bias: CGFloat = 1
    private var fullDetailsOffset: CGFloat { return min(-Layout.Height.userView + bias,
                                                        -(contentView.bounds.height - detailsView.bounds.height))}
    private var lastMoreInfoState: MoreInfoState = MoreInfoState.hidden {
        didSet { moreInfoStateDidChange(oldValue, current: lastMoreInfoState) }
    }

    private var detailsViewFullyVisible: Bool { return scrollView.contentOffset.y - fullDetailsOffset >= -CGFloat.ulpOfOne }
    private let detailsView = ListingCardDetailsView()
    private var detailsThreshold: CGFloat { return 0.5 * previewImageView.height }
    private var isImageVisibleEnough: Bool { return abs(scrollView.contentOffset.y) > detailsThreshold }
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
        recycleDisposeBag()
        previewImageView.image = nil
        userView.alpha = 0
        lastMoreInfoState = .hidden

        layoutVerticalContentInset(animated: false)
    }

    func populateWith(cellModel listingViewModel: ListingCardViewCellModel, imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
        binder.bind(withViewModel: listingViewModel)
        populateWith(details: listingViewModel)
    }

    func populateWith(_ listingSnapshot: ListingDeckSnapshotType, imageDownloader: ImageDownloaderType) {
        self.imageDownloader = imageDownloader
        populateWith(preview: listingSnapshot.preview, imageCount: listingSnapshot.imageCount)
        populateWith(userInfo: listingSnapshot.userInfo)
        detailsView.populateWith(productInfo: listingSnapshot.productInfo)
        detailsView.populateWith(listingStats: nil, postedDate: nil)
    }

    func populateWith(details listingViewModel: ListingCardViewCellModel) {
        detailsView.populateWithViewModel(listingViewModel)
    }

    func populateWith(userInfo: ListingVMUserInfo?) {
        guard let info = userInfo else { return }
        userView.populate(withUserName: info.name, icon: info.avatar, imageDownloader: ImageDownloader.sharedInstance)
        UIView.animate(withDuration: 0.1) { self.userView.alpha = 1 }
    }

    func populateWith(preview: URL?, imageCount: Int) {
        update(pageCount: imageCount)
        guard let previewURL = preview else { return }
        _ = imageDownloader?.downloadImageWithURL(previewURL) { [weak self] (result, url) in
            if let value = result.value {
                DispatchQueue.main.async {
                    self?.previewImageView.image = value.image
                    self?.previewImageView.setNeedsDisplay()
                }
            }
        }
    }

    func populateWith(status: ListingViewModelStatus?, featured: Bool) {
        guard let listingStatus = status else { return }
        statusTapGesture?.isEnabled = featured
        statusView.isHidden = listingStatus.string == nil
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

    func showFullMap(fromRect rect: CGRect) {
        contentView.bringSubview(toFront: detailsView.detailMapView)
        fullMapConstraints = [
            detailsView.detailMapView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            detailsView.detailMapView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1.0)
        ]
        NSLayoutConstraint.activate(fullMapConstraints)

        detailsView.detailMapView.showRegion(animated: true)
        UIView.animate(withDuration: 0.3) {
            self.userView.alpha = 0
            self.whiteGradient.alpha = 0
            self.detailsView.detailMapView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(1)
            self.detailsView.layoutIfNeeded()
        }
    }

    func hideFullMap() {
        detailsView.detailMapView.hideMap(animated: true)
        deactivateFullMap()
        UIView.animate(withDuration: 0.3) {
            self.userView.alpha = 1
            self.whiteGradient.alpha = 1
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
        contentView.clipsToBounds = true
        setupPreviewImageView()
        setupBottomBackground()
        setupImagesCount()
        setupVerticalScrollView()
        setupStatusView()
        setupWhiteGradient()

        backgroundColor = .clear
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
    }

    private func setupBottomBackground() {
        contentView.addSubviewForAutoLayout(bottomBackground)
        bottomBackground.backgroundColor = .white
        bottomBackground.isOpaque = true
        let bottomHeight = bottomBackground.heightAnchor.constraint(equalToConstant: 20)
        NSLayoutConstraint.activate([
            bottomBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomHeight
        ])
        bottomBackgroundHeight = bottomHeight
    }

    private func setupWhiteGradient() {
        whiteGradient.translatesAutoresizingMaskIntoConstraints = false
        whiteGradient.clipsToBounds = true
        whiteGradient.isUserInteractionEnabled = false
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
        statusView.isHidden = true
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
        previewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                 constant: -(DeviceFamily.insetCorrection - 20)).isActive = true
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
        contentView.addSubviewForAutoLayout(scrollView)
        scrollView.layout(with: contentView).leading().trailing().bottom().top()
        scrollView.backgroundColor = .clear
        scrollView.contentInset = defaultContentInset

        userView.clipsToBounds = true
        contentView.addSubviewForAutoLayout(userView)
        userView.heightAnchor.constraint(equalToConstant: Layout.Height.userView).isActive = true

        detailsView.backgroundColor = .white
        detailsView.isUserInteractionEnabled = false
        scrollView.addSubviewForAutoLayout(detailsView)

        detailsView.layout(with: scrollView).fillHorizontal().centerX()
        detailsView.layout(with: scrollView).bottom().centerX().top()

        let scrollTap = UITapGestureRecognizer(target: self, action: #selector(didTapOnScrollView))
        scrollTap.delegate = self
        scrollView.addGestureRecognizer(scrollTap)
        scrollViewTapGesture = scrollTap

        userViewTopConstraints.append(contentsOf: [
            userView.topAnchor.constraint(equalTo: contentView.topAnchor),
            userView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        userViewScrollingConstraints.append(contentsOf: [
            userView.topAnchor.constraint(greaterThanOrEqualTo: gradient.bottomAnchor),
            userView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            detailsView.topAnchor.constraint(equalTo: userView.bottomAnchor)
        ])
        NSLayoutConstraint.activate(userViewScrollingConstraints)
    }

    func updateVerticalContentInset(animated: Bool) {
        let insetWithUser = contentView.height - DeviceFamily.insetCorrection
        if animated {
            layoutVerticalContentInset(animated: animated)
        } else if verticalInset != insetWithUser {
            verticalInset = insetWithUser
            layoutVerticalContentInset(animated: animated)
        }

    }

    func layoutVerticalContentInset(animated: Bool) {
        updateTopInset(verticalInset)
        let duration: TimeInterval = animated ? 0.3 : 0
        let inset = -verticalInset
        UIView.animate(withDuration: duration) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: inset), animated: animated)
        }
    }

    private func updateTopInset(_ inset: CGFloat) {
        let inset = UIEdgeInsets(top: inset, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = inset
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard scrollView.contentInset.top != contentView.height - DeviceFamily.insetCorrection else { return }
        updateTopInset(contentView.height - DeviceFamily.insetCorrection)
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        contentView.layer.cornerRadius = Metrics.margin
        applyShadow(withOpacity: 0.15, radius: Metrics.margin)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: Metrics.margin).cgPath
    }

    // MARK: UIScrollViewDelegate

    private func moreInfoStateDidChange(_ previous: MoreInfoState, current: MoreInfoState) {
        guard previous != current, current == .shown else { return }
        delegate?.didShowMoreInfo()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= -Layout.stickyHeaderThreadshold  {
            setStickyHeaderOn()
        } else {
            setStickyHeaderOff()
        }

        lastMoreInfoState = detailsViewFullyVisible ? .shown : .hidden
        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            let scaleRatio = (-scrollView.contentOffset.y / scrollView.contentInset.top) * 1.2
            previewImageView.transform = CGAffineTransform.identity.scaledBy(x: scaleRatio, y: scaleRatio)
            bottomBackgroundHeight?.constant = 0
        } else {
            if scrollView.contentInset.top != 0
                && -scrollView.contentOffset.y / scrollView.contentInset.top < 0.7 {
                let ratio = -scrollView.contentOffset.y / scrollView.contentInset.top / 0.7
                updateCount(alpha: ratio)
            }
            let diff = scrollView.contentOffset.y - fullDetailsOffset
            bottomBackgroundHeight?.constant = contentView.bounds.height - previewImageView.bounds.height + max(0, diff)
            whiteGradient.alpha = abs(scrollView.contentOffset.y / scrollView.contentInset.top)
        }
        detailsView.isUserInteractionEnabled = !isImageVisibleEnough
    }

    private func setStickyHeaderOn() {
        NSLayoutConstraint.deactivate(userViewScrollingConstraints)
        NSLayoutConstraint.activate(userViewTopConstraints)
        UIView.animate(withDuration: 0.3) {
            self.userView.effectView.alpha = 1
        }
    }

    private func setStickyHeaderOff() {
        NSLayoutConstraint.deactivate(userViewTopConstraints)
        NSLayoutConstraint.activate(userViewScrollingConstraints)
        UIView.animate(withDuration: 0.3) {
            self.userView.effectView.alpha = 0
        }
    }

    private func updateCount(alpha: CGFloat) {
        countImageView.alpha = alpha
        imageCountLabel.alpha = alpha
        gradient.alpha = alpha
    }

    private func showFullImagePreview() {
        detailsView.isUserInteractionEnabled = false
        let offsetY = -scrollView.contentInset.top
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
        let offsetY = fullDetailsOffset
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseIn, animations: { [weak self] in
                        self?.scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
            }, completion: nil)
    }

    func delayedOnboardingFlashDetails(withDelay delayed: Double, duration: TimeInterval) {
        let currentOffset = scrollView.contentOffset
        let flashOffset = CGPoint(x: 0, y: currentOffset.y + 20)
        let duration: TimeInterval = 0.2
        delay(delayed) {
            UIView.animate(withDuration: duration / 2, animations: { [weak self] in
                self?.scrollView.setContentOffset(flashOffset, animated: true)
            })
            delay(duration / 2) { [weak self] in // otherwise this won't work as expected
                UIView.animate(withDuration: duration / 2, animations: { [weak self] in
                    self?.scrollView.setContentOffset(currentOffset, animated: true)
                })
            }
        }
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

fileprivate extension DeviceFamily {
    static var insetCorrection: CGFloat {
        switch DeviceFamily.current {
        case .iPhone6Plus: return 134
        case .biggerUnknown: return 134 // iPhoneX
        case .iPhone4: return 76
        case .iPhone5: return 86
        case .iPhone6: return 125
        }
    }
}

