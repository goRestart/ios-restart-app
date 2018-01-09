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

final class ListingCardDetailsView: UIView, SocialShareViewDelegate {
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

    private let mapHeader = UIStackView()
    private let locationLabel = UILabel()
    private let mapPlaceHolder = UIView()

    let detailMapView = ListingCardDetailMapView()
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
        locationLabel.text = productInfo.address
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

    private func enableSocialView(_ enabled: Bool) {
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
            headerStackView.layoutMargins = UIEdgeInsets(top: Metrics.margin, left: Metrics.margin,
                                                         bottom: 0, right: Metrics.margin)
            headerStackView.spacing = 0
            headerStackView.addArrangedSubview(titleLabel)
            headerStackView.addArrangedSubview(priceLabel)

            scrollView.addSubview(headerStackView)
            headerStackView.translatesAutoresizingMaskIntoConstraints = false
            headerStackView.layout(with: scrollView).top().leadingMargin().trailingMargin()
        }

        func setupTitleLabel() {
            titleLabel.font = UIFont.systemMediumFont(size: 17)
            titleLabel.textAlignment = .left
            titleLabel.numberOfLines = 1
            titleLabel.setContentHuggingPriority(.required, for: .vertical)
        }

        func setupPriceLabel() {
            priceLabel.font = UIFont.systemBoldFont(size: 27)
            priceLabel.textAlignment = .left
            priceLabel.numberOfLines = 1
            priceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        }

        setupHeaderStackView()
        setupTitleLabel()
        setupPriceLabel()
    }

    private func setupDetailUI() {
        scrollView.addSubview(detailLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        detailLabel.layout(with: headerStackView).below(by: Metrics.veryShortMargin)
        detailLabel.layout(with: scrollView).leadingMargin(by: Metrics.shortMargin).trailingMargin(by: -Metrics.shortMargin)
        detailLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        detailLabel.isUserInteractionEnabled = true
        detailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleDetailLines)))
        detailLabel.numberOfLines = 3
        detailLabel.textAlignment = .left
        detailLabel.font = UIFont.systemRegularFont(size: 15)
        detailLabel.textColor = #colorLiteral(red: 0.7803921569, green: 0.8078431373, blue: 0.7803921569, alpha: 1)
    }

    private func setupStatsView() {
        scrollView.addSubview(statsView)
        statsView.translatesAutoresizingMaskIntoConstraints = false
        statsView.layout(with: detailLabel).below(by: Metrics.margin)
        statsView.layout(with: scrollView)
            .leadingMargin(by: Metrics.shortMargin).trailingMargin(by: -Metrics.shortMargin)
        statsView.updateStatsWithInfo(100, favouritesCount: 80, postedDate: Date())
    }

    private func setupMapView() {
        func setupLocationLabel() {
            locationLabel.font = UIFont.systemMediumFont(size: 13)
            locationLabel.textAlignment = .left
            locationLabel.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)

            locationLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            locationLabel.setContentHuggingPriority(.required, for: .vertical)
        }
        func setupMapHeader() {
            mapHeader.translatesAutoresizingMaskIntoConstraints = false
            mapHeader.axis = .horizontal
            mapHeader.distribution = .fillProportionally
            scrollView.addSubview(mapHeader)
            mapHeader.layout(with: scrollView).leadingMargin().trailingMargin()
            mapHeader.layout(with: statsView).below(by: Metrics.margin)
            mapHeader.setContentCompressionResistancePriority(.required, for: .vertical)

            let location = UIImageView(image: #imageLiteral(resourceName: "nit_location"))
            location.contentMode = .center
            location.layout().width(24)

            mapHeader.addArrangedSubview(location)
            mapHeader.addArrangedSubview(locationLabel)
        }

        func setupSnapShotView() {
            detailMapView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(detailMapView)

            mapPlaceHolder.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(mapPlaceHolder)

            mapPlaceHolder.layout(with: scrollView)
                .leadingMargin(by: Metrics.shortMargin).trailingMargin(by: -Metrics.shortMargin)
            mapPlaceHolder.topAnchor.constraint(equalTo: mapHeader.bottomAnchor,
                                                constant: Metrics.shortMargin).isActive = true
            mapPlaceHolder.layout().height(Layout.Height.mapView)
            mapPlaceHolder.backgroundColor = backgroundColor
            
            let centerY = detailMapView.centerYAnchor.constraint(equalTo: mapPlaceHolder.centerYAnchor)
            centerY.priority = UILayoutPriority(rawValue: 999)
            centerY.isActive = true
            
            detailMapView.layout(with: scrollView).fillHorizontal()
            let mapHeightConstraint = detailMapView.heightAnchor.constraint(equalToConstant: Layout.Height.mapView)
            mapHeightConstraint.isActive = true
            mapHeightConstraint.priority = UILayoutPriority(rawValue: 999)
            
            mapSnapShotToBottom = mapPlaceHolder.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor,
                                                                          constant: -2*Metrics.margin)
            detailMapView.isUserInteractionEnabled = true
        }
        setupLocationLabel()
        setupMapHeader()
        setupSnapShotView()
    }

    private func setupSocialMedia() {
        func setupSocialMediaHeader() {
            socialMediaHeader.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(socialMediaHeader)

            mapSnapShotToSocialView = socialMediaHeader.topAnchor.constraint(equalTo: mapPlaceHolder.bottomAnchor,
                                                                             constant: 2*Metrics.margin)
            mapSnapShotToSocialView?.isActive = true

            socialMediaHeader.layout(with: scrollView).leadingMargin(by: Metrics.margin).trailingMargin(by: -Metrics.margin)

            socialMediaHeader.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
            socialMediaHeader.font = UIFont.systemRegularFont(size: 13)
            socialMediaHeader.textAlignment = .left
            socialMediaHeader.text = LGLocalizedString.productShareTitleLabel
            socialMediaHeader.setContentCompressionResistancePriority(.required, for: .vertical)
            socialMediaHeader.setContentHuggingPriority(.required, for: .vertical)
        }

        func setupSocialView() {
            socialShareView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(socialShareView)
            socialShareView.topAnchor.constraint(equalTo: socialMediaHeader.bottomAnchor,
                                                 constant: Metrics.shortMargin).isActive = true
            socialShareView.layout(with: scrollView).leadingMargin().trailingMargin()
            socialShareView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor,
                                                    constant: -2*Metrics.margin).isActive = true

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
