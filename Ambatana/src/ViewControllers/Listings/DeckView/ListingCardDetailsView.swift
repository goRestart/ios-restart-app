//
//  ListingCardDetailsView.swift
//  LetGo
//
//  Created by Facundo Menzella on 06/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import MapKit
import LGCoreKit

fileprivate struct DetailNumberOfLines {
    let current: Int
    fileprivate let next: Int

    func toggle() -> DetailNumberOfLines {
        return DetailNumberOfLines(current: next, next: current)
    }
}

protocol ListingCardDetailsViewDelegate: class {
    func viewControllerToShowShareOptions() -> UIViewController
}

final class ListingCardDetailsView: UIView, SocialShareViewDelegate, ListingCardDetailsViewType {
    private struct Layout { struct Height { static let mapView: CGFloat = 128.0  } }

    var delegate: (ListingCardDetailsViewDelegate & ListingCardDetailMapViewDelegate)? {
        didSet { detailMapView.delegate = delegate }
    }

    private let scrollView = UIScrollView()

    private let headerStackView = UIStackView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()

    private let detailLabel = UILabel()
    private let statsView = ListingStatsView.make()!

    private var locationToStats: NSLayoutConstraint?
    private var locationToDetail: NSLayoutConstraint?

    let detailMapView = ListingCardDetailMapView()
    let mapPlaceHolder = UIView()
    var isMapExpanded: Bool { return detailMapView.isExpanded }
    private var mapSnapShotToBottom: NSLayoutConstraint?
    private var mapSnapShotToSocialView: NSLayoutConstraint?

    private let socialMediaHeader = UILabel()
    private let socialShareView = SocialShareView()

    private var detailNumberOfLines = DetailNumberOfLines(current: 3, next: 0)

    private let binder = ListingCardDetailsViewBinder()

    convenience init() {
        self.init(frame: .zero)
        setupUI()
        binder.detailsView = self
    }

    // MARK: PopulateView

    func populateWithViewModel(_ viewModel: ListingCardDetailsViewModel) {
        binder.bind(to:viewModel)
    }

    func populateWith(productInfo: ListingVMProductInfo) {
        if let location = productInfo.location {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)

            let region = MKCoordinateRegion(center: center, span: span)
            detailMapView.setRegion(region, size: CGSize(width: 300, height: 500))
        }
        titleLabel.text = productInfo.title
        priceLabel.text = productInfo.price
        detailLabel.attributedText = productInfo.description
        detailMapView.setLocationName(productInfo.address)
    }

    func populateWith(listingStats: ListingStats, postedDate: Date?) {
        statsView.updateStatsWithInfo(listingStats.viewsCount,
                                      favouritesCount: listingStats.viewsCount,
                                      postedDate: postedDate)
    }

    func populateWith(socialSharer: SocialSharer) {
        socialShareView.socialSharer = socialSharer
    }

    func populateWith(socialMessage: SocialMessage?) {
        socialShareView.socialMessage = socialMessage
        enableSocialView(socialMessage != nil)
    }

    func disableStatsView() {
        locationToStats?.isActive = false
        locationToDetail?.isActive = true
    }

    private func enableSocialView(_ enabled: Bool) {
        socialShareView.isHidden = !enabled
        socialMediaHeader.isHidden = !enabled
        mapSnapShotToBottom?.isActive = !enabled
        mapSnapShotToSocialView?.isActive = enabled
    }

    // MARK: SetupView
    private func setupUI() {
        setupScrollView()
        setupHeaderUI()
        setupDetailUI()
        setupStatsView()
        setupMapView()
        setupSocialMedia()
    }

    private func setupScrollView() {
        func fixScrollViewWidth() {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(view)
            scrollView.showsVerticalScrollIndicator = false

            view.backgroundColor = .white
            view.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            view.layout(with: scrollView).fillHorizontal()
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.layout(with: self).fill()

        fixScrollViewWidth()
    }

    private func setupHeaderUI() {
        func setupHeaderStackView() {
            headerStackView.axis = .vertical
            headerStackView.distribution = .fillProportionally
            headerStackView.isLayoutMarginsRelativeArrangement = true
            headerStackView.layoutMargins = .zero

            headerStackView.spacing = 0
            headerStackView.addArrangedSubview(titleLabel)
            headerStackView.addArrangedSubview(priceLabel)

            scrollView.addSubview(headerStackView)
            headerStackView.translatesAutoresizingMaskIntoConstraints = false
            headerStackView.layout(with: scrollView)
                .top(by: Metrics.margin)
                .leading(by: Metrics.margin).trailing(by: -Metrics.margin)
        }

        func setupTitleLabel() {
            titleLabel.font = UIFont.deckTitleFont
            titleLabel.textAlignment = .left
            titleLabel.numberOfLines = 1
            titleLabel.setContentHuggingPriority(.required, for: .vertical)
            titleLabel.backgroundColor = UIColor.white
        }

        func setupPriceLabel() {
            priceLabel.font = UIFont.deckPriceFont
            priceLabel.textAlignment = .left
            priceLabel.numberOfLines = 1
            priceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            priceLabel.backgroundColor = UIColor.white
        }

        setupHeaderStackView()
        setupTitleLabel()
        setupPriceLabel()
    }

    private func setupDetailUI() {
        scrollView.addSubview(detailLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        detailLabel.layout(with: headerStackView).below(by: Metrics.veryShortMargin)
        detailLabel.layout(with: scrollView).leading(by: Metrics.margin).trailing(by: -Metrics.margin)
        detailLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        detailLabel.isUserInteractionEnabled = true
        detailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleDetailLines)))
        detailLabel.numberOfLines = 3
        detailLabel.textAlignment = .left
        detailLabel.font = UIFont.deckDetailFont
        detailLabel.textColor = #colorLiteral(red: 0.7803921569, green: 0.8078431373, blue: 0.7803921569, alpha: 1)
        detailLabel.backgroundColor = UIColor.white
    }

    private func setupStatsView() {
        scrollView.addSubview(statsView)
        statsView.translatesAutoresizingMaskIntoConstraints = false
        statsView.layout(with: detailLabel).below(by: Metrics.bigMargin)
        statsView.layout(with: scrollView).leading(by: Metrics.margin).trailing(by: -Metrics.margin)
        statsView.timePostedView.layer.borderColor = UIColor.grayLight.cgColor
        statsView.timePostedView.layer.borderWidth = 1.0
        statsView.backgroundColor = UIColor.white
    }

    private func setupMapView() {
        mapPlaceHolder.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mapPlaceHolder)
        mapPlaceHolder.layout().height(Layout.Height.mapView)
        mapPlaceHolder.layout(with: scrollView).fillHorizontal()
        mapPlaceHolder.backgroundColor = backgroundColor

        locationToStats = mapPlaceHolder.topAnchor.constraint(equalTo: statsView.bottomAnchor,
                                                              constant: 2*Metrics.margin)
        mapSnapShotToBottom = mapPlaceHolder.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor,
                                                                     constant: -2*Metrics.margin)

        locationToStats?.isActive = true
        locationToDetail = mapPlaceHolder.topAnchor.constraint(equalTo: detailLabel.bottomAnchor)

        detailMapView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(detailMapView)
        detailMapView.layout(with: scrollView).fillHorizontal()

        let centerY = detailMapView.centerYAnchor.constraint(equalTo: mapPlaceHolder.centerYAnchor)
        centerY.priority = UILayoutPriority(rawValue: 999)
        centerY.isActive = true

        let mapHeightConstraint = detailMapView.heightAnchor.constraint(equalTo: mapPlaceHolder.heightAnchor,
                                                                        multiplier: 1.0)
        mapHeightConstraint.isActive = true
        mapHeightConstraint.priority = UILayoutPriority(rawValue: 999)
        detailMapView.isUserInteractionEnabled = true
    }

    private func setupSocialMedia() {
        func setupSocialMediaHeader() {
            socialMediaHeader.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(socialMediaHeader)

            mapSnapShotToSocialView = socialMediaHeader.topAnchor.constraint(equalTo: mapPlaceHolder.bottomAnchor,
                                                                             constant: 2*Metrics.margin)
            mapSnapShotToSocialView?.isActive = true

            socialMediaHeader.layout(with: scrollView)
                .leading(by: Metrics.margin).trailing(by: -Metrics.margin)

            socialMediaHeader.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
            socialMediaHeader.backgroundColor = UIColor.white
            socialMediaHeader.font = UIFont.deckSocialHeaderFont
            socialMediaHeader.textAlignment = .left
            socialMediaHeader.text = LGLocalizedString.productShareTitleLabel
            socialMediaHeader.setContentCompressionResistancePriority(.required, for: .vertical)
            socialMediaHeader.setContentHuggingPriority(.required, for: .vertical)
        }

        func setupSocialView() {
            socialShareView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(socialShareView)
            socialShareView.topAnchor.constraint(equalTo: socialMediaHeader.bottomAnchor).isActive = true
            socialShareView.layout(with: scrollView)
                .leading(by: 7.0).trailing(by: -7.0)
            socialShareView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor,
                                                    constant: -2*Metrics.margin).isActive = true
            socialShareView.setupBackgroundColor(.white)
            socialShareView.delegate = self
        }

        setupSocialMediaHeader()
        setupSocialView()
    }

    // MARK: Actions
    @objc private func toggleDetailLines() {
        detailNumberOfLines = detailNumberOfLines.toggle()
        detailLabel.numberOfLines = detailNumberOfLines.current

        scrollView.layoutIfNeeded()
    }

    // MARK: - SocialShareViewDelegate
    func viewController() -> UIViewController? {
        return delegate?.viewControllerToShowShareOptions()
    }
}
