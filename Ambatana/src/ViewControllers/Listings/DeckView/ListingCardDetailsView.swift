//
//  ListingCardDetailsView.swift
//  LetGo
//
//  Created by Facundo Menzella on 06/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
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
        struct Margin {
            static let statsToDetail: CGFloat = 30
            static let socialView: CGFloat = -3
        }
    }
    private struct Colors {
        static let headerColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
    }
    private struct Map {
        static let snapshotSize = CGSize(width: 300, height: 500)
    }

    var delegate: (ListingCardDetailsViewDelegate & ListingCardDetailMapViewDelegate)? {
        didSet { detailMapView.delegate = delegate }
    }

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.spacing = 0
        return stackView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.deckTitleFont
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .white
        return label
    }()
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.deckPriceFont
        label.textAlignment = .left
        label.numberOfLines = 1
        label.backgroundColor = .white
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.isUserInteractionEnabled = true
        label.numberOfLines = 3
        label.textAlignment = .left
        label.font = UIFont.deckDetailFont
        label.textColor = .grayDark
        label.backgroundColor = .white
        return label
    }()
    private let statsView: ListingStatsView = {
        let view = ListingStatsView.make(withStyle: .light)!
        view.timePostedView.layer.borderColor = UIColor.grayLight.cgColor
        view.timePostedView.layer.borderWidth = 1.0
        view.backgroundColor = UIColor.white
        return view
    }()

    private var locationToStats: NSLayoutConstraint?
    private var locationToDetail: NSLayoutConstraint?

    let detailMapView = ListingCardDetailMapView()
    private var mapSnapShotToBottom: NSLayoutConstraint?
    private var mapSnapShotToSocialView: NSLayoutConstraint?

    private let socialMediaHeader: UILabel = {
        let label = UILabel()
        label.textColor = Colors.headerColor
        label.backgroundColor = UIColor.white
        label.font = UIFont.deckSocialHeaderFont
        label.textAlignment = .left
        label.text = LGLocalizedString.productShareTitleLabel
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    private let socialShareView: SocialShareView = {
        let view = SocialShareView()
        view.style = .grid
        view.gridColumns = 4
        return view
    }()

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

    func populateWith(productInfo: ListingVMProductInfo?, showExactLocationOnMap: Bool) {
        guard let info = productInfo else { return }
        if let location = info.location {
            detailMapView.setLocation(location,
                                      size: Map.snapshotSize,
                                      showExactLocationOnMap: showExactLocationOnMap)
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
        addSubviewsForAutoLayout([headerStackView, detailLabel, statsView,
                                  detailMapView, socialMediaHeader, socialShareView])
        setupHeaderUI()
        setupDetailUI()
        setupStatsView()
        setupMapPlaceHolder()
        setupSocialMedia()
    }

    private func setupHeaderUI() {
        headerStackView.addArrangedSubview(priceLabel)
        headerStackView.addArrangedSubview(titleLabel)

        headerStackView
            .layout(with: self)
            .top(by: Metrics.margin)
            .fillHorizontal(by: Metrics.veryShortMargin)
    }

    private func setupDetailUI() {
        detailLabel
            .layout(with: headerStackView)
            .below(by: Metrics.veryShortMargin)
        detailLabel
            .layout(with: self)
            .fillHorizontal(by: Metrics.veryShortMargin)
        detailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleDetailLines)))
    }

    private func setupStatsView() {
        statsView
            .layout(with: detailLabel)
            .below(by: Layout.Margin.statsToDetail)
        statsView
            .layout(with: self)
            .fillHorizontal(by: Metrics.veryShortMargin)
    }

    private func setupMapPlaceHolder() {
        detailMapView
            .layout(with: self)
            .fillHorizontal()
        detailMapView.layout().height(Layout.Height.mapView)
        detailMapView.isUserInteractionEnabled = true
        locationToStats = detailMapView.topAnchor.constraint(equalTo: statsView.bottomAnchor,
                                                              constant: 2*Metrics.margin)
        locationToStats?.isActive = true
        mapSnapShotToBottom = detailMapView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                                     constant: -2*Metrics.margin)
        locationToDetail = detailMapView.topAnchor.constraint(equalTo: detailLabel.bottomAnchor)
    }

    private func setupSocialMedia() {
        func setupSocialMediaHeader() {
            mapSnapShotToSocialView = socialMediaHeader.topAnchor.constraint(equalTo: detailMapView.bottomAnchor,
                                                                             constant: 2*Metrics.margin)
            mapSnapShotToSocialView?.isActive = true
            socialMediaHeader
                .layout(with: self)
                .fillHorizontal(by: Metrics.shortMargin)
        }

        func setupSocialView() {
            socialShareView.topAnchor.constraint(equalTo: socialMediaHeader.bottomAnchor).isActive = true
            socialShareView
                .layout(with: self)
                .fillHorizontal(by: Layout.Margin.socialView)
            socialShareView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                    constant: -2*Metrics.margin).isActive = true
            socialShareView.setupBackgroundColor(.white)
            socialShareView.delegate = self
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
