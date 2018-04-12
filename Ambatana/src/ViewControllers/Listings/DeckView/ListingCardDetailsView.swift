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
    private struct Layout {
        struct Height { static let mapView: CGFloat = 136.0  }
        struct Margin { static let statsToDetail: CGFloat = 30 }
    }

    var delegate: (ListingCardDetailsViewDelegate & ListingCardDetailMapViewDelegate)? {
        didSet { detailMapView.delegate = delegate }
    }

    private let headerStackView = UIStackView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()

    private let detailLabel = UILabel()
    private let statsView = ListingStatsView.make(withStyle: .light)!

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

    private lazy var binder = ListingCardDetailsViewBinder()

    convenience init() {
        self.init(frame: .zero)
        setupUI()
    }

    // MARK: PopulateView

    func populateWithViewModel(_ viewModel: ListingCardDetailsViewModel) {
        binder.detailsView = self
        binder.bind(to:viewModel)
        setNeedsLayout()
    }

    func populateWith(productInfo: ListingVMProductInfo?) {
        guard let info = productInfo else { return }
        if let location = info.location {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)

            let region = MKCoordinateRegion(center: center, span: span)
            detailMapView.setRegion(region, size: CGSize(width: 300, height: 500))
        }
        titleLabel.text = info.title
        titleLabel.isHidden = info.title == nil
        priceLabel.text = info.price

        detailLabel.attributedText = info.description?.stringByRemovingLinks
        detailMapView.setLocationName(info.address)
        setNeedsLayout()
    }

    func populateWith(listingStats: ListingStats?, postedDate: Date?) {
        guard let stats = listingStats else {
            statsView.alpha = 0
            return
        }
        guard  stats.viewsCount >= Constants.minimumStatsCountToShow
            || stats.favouritesCount >= Constants.minimumStatsCountToShow
            || postedDate != nil else {
                statsView.alpha = 0
                return
        }
        statsView.updateStatsWithInfo(stats.viewsCount,
                                      favouritesCount: stats.favouritesCount,
                                      postedDate: postedDate)
        UIView.animate(withDuration: 0.3) { self.statsView.alpha = 1 }
        setNeedsLayout()
    }

    func populateWith(socialSharer: SocialSharer) {
        socialShareView.socialSharer = socialSharer
    }

    func populateWith(socialMessage: SocialMessage?) {
        socialShareView.socialMessage = socialMessage
        enableSocialView(socialMessage != nil)
        setNeedsLayout()
    }

    func setStatsViewActive(_ active: Bool) {
        locationToStats?.isActive = active
        locationToDetail?.isActive = !active
        setNeedsLayout()
    }

    private func enableSocialView(_ enabled: Bool) {
        socialShareView.isHidden = !enabled
        socialMediaHeader.isHidden = !enabled
        mapSnapShotToBottom?.isActive = !enabled
        mapSnapShotToSocialView?.isActive = enabled
        setNeedsLayout()
    }

    // MARK: SetupView
    private func setupUI() {
        backgroundColor = .white
        setupHeaderUI()
        setupDetailUI()
        setupStatsView()
        setupMapPlaceHolder()
        setupSocialMedia()
        setupMapView()
    }

    private func setupHeaderUI() {
        func setupHeaderStackView() {
            headerStackView.axis = .vertical
            headerStackView.distribution = .fillProportionally
            headerStackView.isLayoutMarginsRelativeArrangement = true
            headerStackView.layoutMargins = .zero

            headerStackView.spacing = 0
            headerStackView.addArrangedSubview(priceLabel)
            headerStackView.addArrangedSubview(titleLabel)

            addSubview(headerStackView)
            headerStackView.translatesAutoresizingMaskIntoConstraints = false
            headerStackView.layout(with: self)
                .top(by: Metrics.margin)
                .leading(by: Metrics.margin).trailing(by: -Metrics.margin)
        }

        func setupTitleLabel() {
            titleLabel.font = UIFont.deckTitleFont
            titleLabel.textAlignment = .left
            titleLabel.numberOfLines = 0
            titleLabel.backgroundColor = UIColor.white
        }

        func setupPriceLabel() {
            priceLabel.font = UIFont.deckPriceFont
            priceLabel.textAlignment = .left
            priceLabel.numberOfLines = 1
            priceLabel.backgroundColor = UIColor.white
        }

        setupHeaderStackView()
        setupPriceLabel()
        setupTitleLabel()
    }

    private func setupDetailUI() {
        addSubview(detailLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        detailLabel.layout(with: headerStackView).below(by: Metrics.veryShortMargin)
        detailLabel.layout(with: self).leading(by: Metrics.margin).trailing(by: -Metrics.margin)
        detailLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        detailLabel.isUserInteractionEnabled = true
        detailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleDetailLines)))
        detailLabel.numberOfLines = 3
        detailLabel.textAlignment = .left
        detailLabel.font = UIFont.deckDetailFont
        detailLabel.textColor = .grayDark
        detailLabel.backgroundColor = UIColor.white
    }

    private func setupStatsView() {
        addSubview(statsView)
        statsView.translatesAutoresizingMaskIntoConstraints = false
        statsView.layout(with: detailLabel).below(by: Layout.Margin.statsToDetail)
        statsView.layout(with: self).leading(by: Metrics.margin).trailing(by: -Metrics.margin)
        statsView.timePostedView.layer.borderColor = UIColor.grayLight.cgColor
        statsView.timePostedView.layer.borderWidth = 1.0
        statsView.backgroundColor = UIColor.white
    }

    private func setupMapView() {
        addSubviewForAutoLayout(detailMapView)
        detailMapView.layout(with: self).fillHorizontal()
        let height = detailMapView.heightAnchor.constraint(equalTo: mapPlaceHolder.heightAnchor)
        height.priority = .required - 1
        let centerY = detailMapView.centerYAnchor.constraint(equalTo: mapPlaceHolder.centerYAnchor)
        centerY.priority = .defaultLow
        let constraints = [centerY, height]

        detailMapView.isUserInteractionEnabled = true
        NSLayoutConstraint.activate(constraints)
    }

    private func setupMapPlaceHolder() {
        mapPlaceHolder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mapPlaceHolder)
        mapPlaceHolder.layout().height(Layout.Height.mapView)
        mapPlaceHolder.layout(with: self).fillHorizontal()
        mapPlaceHolder.backgroundColor = backgroundColor

        locationToStats = mapPlaceHolder.topAnchor.constraint(equalTo: statsView.bottomAnchor,
                                                              constant: 2*Metrics.margin)
        locationToStats?.isActive = true

        mapSnapShotToBottom = mapPlaceHolder.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                                     constant: -2*Metrics.margin)
        mapSnapShotToBottom?.isActive = false

        locationToDetail = mapPlaceHolder.topAnchor.constraint(equalTo: detailLabel.bottomAnchor)
    }

    private func setupSocialMedia() {
        func setupSocialMediaHeader() {
            socialMediaHeader.translatesAutoresizingMaskIntoConstraints = false
            addSubview(socialMediaHeader)

            mapSnapShotToSocialView = socialMediaHeader.topAnchor.constraint(equalTo: mapPlaceHolder.bottomAnchor,
                                                                             constant: 2*Metrics.margin)
            mapSnapShotToSocialView?.isActive = true
            socialMediaHeader.layout(with: self).fillHorizontal(by: Metrics.margin)

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
            addSubview(socialShareView)
            socialShareView.topAnchor.constraint(equalTo: socialMediaHeader.bottomAnchor).isActive = true
            socialShareView.layout(with: self).fillHorizontal(by: 7.0)
            socialShareView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                    constant: -2*Metrics.margin).isActive = true
            socialShareView.setupBackgroundColor(.white)
            socialShareView.delegate = self
            socialShareView.style = .grid
            socialShareView.gridColumns = 4
        }

        setupSocialMediaHeader()
        setupSocialView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.preferredMaxLayoutWidth = headerStackView.bounds.width
        priceLabel.preferredMaxLayoutWidth = headerStackView.bounds.width
        detailLabel.preferredMaxLayoutWidth = headerStackView.bounds.width
    }

    // MARK: Actions
    @objc private func toggleDetailLines() {
        detailNumberOfLines = detailNumberOfLines.toggle()
        detailLabel.numberOfLines = detailNumberOfLines.current

        setNeedsLayout()
    }

    // MARK: - SocialShareViewDelegate
    func viewController() -> UIViewController? {
        return delegate?.viewControllerToShowShareOptions()
    }
}
