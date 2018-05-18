//
//  LGMapView.swift
//  LetGo
//
//  Created by Tomas Cobo on 30/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import LGCoreKit
import RxSwift
import RxCocoa
import RxMKMapView

protocol LGMapViewDelegate: class {
    func gpsButtonTapped()
    func retryButtonTapped(location: LGLocationCoordinates2D, radius: Int)
    func detailTapped(_ listing: Listing, originImageView: UIImageView?)
}

final class LGMapView: UIView {
    
    private let disposeBag = DisposeBag()
    
    private let mkAnnotationsVariable: Variable<[MKAnnotation]?> = Variable(nil)
    let selectedAnnotationIndexVariable: Variable<Int?> = Variable(nil)
    
    let showMapError = Variable(false)
    
    private var isDetailMapVisible = false
    private var detailMapTopConstraint: NSLayoutConstraint?
    private var retryTopConstraint: NSLayoutConstraint?
    
    weak var delegate: LGMapViewDelegate?
    
    // MARK: - Subviews
    
    let mapView: MKMapView = MKMapView()
    
    private let gpsLocationButton: UIButton = {
        let button = UIButton()
        button.cornerRadius = LGMapViewMetrics.gpsButtonCornerRadius
        button.setImage(#imageLiteral(resourceName: "map_user_location_button"), for: .normal)
        return button
    }()
    
    private let detailMap: LGMapDetailView = {
        let detailMap = LGMapDetailView(imageDownloader: ImageDownloader.sharedInstance)
        detailMap.applyFloatingButtonShadow()
        return detailMap
    }()
    
    private let topViewsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.layoutMargins = .zero
        stackView.spacing = Metrics.shortMargin
        stackView.clipsToBounds = true
        return stackView
    }()
    
    private let mapMessageView: LGMapMessageView = {
        let view = LGMapMessageView()
        view.backgroundColor = .white
        view.alpha = 0
        view.isHidden = true
        view.cornerRadius = LGMapViewMetrics.messageRadius
        view.applyDefaultShadow()
        return view
    }()
    
    private let retryView: LGMapRetryView = {
        let view = LGMapRetryView()
        view.alpha = 0.0
        view.isHidden = true
        return view
    }()
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setupRx()
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //  MARK: - Private
    
    private func setupUI() {
        gpsLocationButton.addTarget(self, action: #selector(gpsButtonPressed), for: .touchUpInside)
        
        mapView.delegate = self
        retryView.delegate = self
        detailMap.delegate = self
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didDragMap(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        topViewsStackView.addArrangedSubview(mapMessageView)
        topViewsStackView.addArrangedSubview(retryView)
        addSubviewsForAutoLayout([mapView, topViewsStackView, gpsLocationButton, detailMap])
        
        mapView.layout(with: self).fill()
        topViewsStackView.layout(with: self).fillHorizontal(by: Metrics.margin)
        retryTopConstraint = topViewsStackView.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.margin)
        retryTopConstraint?.isActive = true
        
        gpsLocationButton.layout(with: self).below(by: Metrics.shortMargin).right()
        gpsLocationButton.layout().height(LGMapViewMetrics.gpsIconSize.height).width(LGMapViewMetrics.gpsIconSize.width)
        
        detailMap.layout(with: self).fillHorizontal()
        
        detailMapTopConstraint = detailMap.topAnchor.constraint(equalTo: bottomAnchor)
        detailMapTopConstraint?.isActive = true
        
        retryView.layout().height(LGMapViewMetrics.retryButtonHeight)
    }
    
    private func setupRx() {
        mkAnnotationsVariable
            .asDriver()
            .drive(onNext: { [weak self] annotations in
                guard let annotations = annotations else { return }
                self?.mapMessageView.isHidden = !annotations.isEmpty
                self?.mapMessageView.animateTo(alpha:annotations.isEmpty ? 1 : 0)
                self?.showRetryView(shouldShow: annotations.isEmpty)
            }).disposed(by: disposeBag)
        mkAnnotationsVariable
            .asObservable()
            .unwrap()
            .bind(to: mapView.rx.annotations)
            .disposed(by: disposeBag)
        mapView.rx.didSelectAnnotationView
            .subscribe(onNext: { [weak self] annotationView in
                guard let lgAnnotationView = annotationView.annotation as? LGMapAnnotation else { return }
                annotationView.image = lgAnnotationView.selectedAnnotation
                self?.centerMap(location: lgAnnotationView.location, animated: true)
                self?.selectedAnnotationIndexVariable.value = self?.mkAnnotationsVariable.value?.index(where: { $0 === lgAnnotationView })
            }).disposed(by: disposeBag)
        mapView.rx.didDeselectAnnotationView
            .subscribe(onNext: { [weak self] annotationView in
                guard let lgAnnotationView = annotationView.annotation as? LGMapAnnotation else { return }
                annotationView.image = lgAnnotationView.deselectedAnnotation
                self?.showDetail(false)
            }).disposed(by: disposeBag)
        
        showMapError
            .asDriver()
            .drive(onNext: { [weak self] error in
            self?.retryTopConstraint?.constant = error ? LGMapViewMetrics.retryButtonMarginError : Metrics.margin
        }).disposed(by: disposeBag)
        
    }
    
    private func showNoResultMessage() {
        mapMessageView.updateMessage(with: LGLocalizedString.listingsMapNoResultsMessage)
    }
    
    private func showDetail(_ show: Bool) {
        if !isDetailMapVisible && show {
            updateDetailConstraint(toShowDetail: true)
        } else if isDetailMapVisible && !show {
            updateDetailConstraint(toShowDetail: false)
        }
    }
    
    private func updateDetailConstraint(toShowDetail showDetail: Bool) {
        isDetailMapVisible = showDetail
        detailMapTopConstraint?.constant = showDetail ? -detailMap.height : 0
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 2,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                        self?.layoutIfNeeded()
        })
    }
    
    //  MARK: - Public
    
    func updateMapRegion(location: LGLocationCoordinates2D?,
                         radiusAccuracy: Double = Constants.nonAccurateRegionRadius,
                         animated: Bool = false) {
        guard let region = location?.region(radiusAccuracy: radiusAccuracy) else { return }
        mapView.setRegion(region, animated: animated)
    }
    
    func centerMap(location: LGLocationCoordinates2D?, animated: Bool = false) {
        guard let location = location?.coordinates2DfromLocation() else { return }
        mapView.setCenter(location, animated: animated)
    }
    
    func update(annotations: [MKAnnotation]) {
        if annotations.isEmpty {
            showNoResultMessage()
        } else {
            mkAnnotationsVariable.value = annotations
        }
    }
    
    func update(loading: Bool) {
        retryView.isLoading.value = loading
    }
    
    func updateDetail(with listing: Listing, tags: [String]) {
        detailMap.update(with: listing, tags: tags)
        showDetail(true)
    }
    
    func resetMap() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    //  MARK: - Actions
    
    @objc private func gpsButtonPressed() {
        delegate?.gpsButtonTapped()
    }
    
    private var startPanLocation: CGPoint = .zero
    
    private func showRetryView(shouldShow: Bool) {
        let alpha: CGFloat = shouldShow ? 1.0 : 0.0
        if retryView.isHidden == shouldShow {
            retryView.isHidden = !shouldShow
            retryView.animateTo(alpha: alpha)
        }
    }
    
    @objc private func didDragMap(_ panRecognizer: UIPanGestureRecognizer) {
        
        let currentLocation = panRecognizer.location(in: self)
        
        switch panRecognizer.state {
        case .began:
            startPanLocation = currentLocation
        case .ended:
            let dx = currentLocation.x - startPanLocation.x
            let dy = currentLocation.y - startPanLocation.y
            let distance = sqrt(dx*dx + dy*dy)
            if distance > 20 {
                showRetryView(shouldShow: true)
            }
        default: break
        }
    }
}

extension LGMapView: LGMapRetryViewDelegate {
    func retryTapped() {
        guard let location = LGLocationCoordinates2D(coordinates: mapView.centerCoordinate) else { return }
        delegate?.retryButtonTapped(location: location, radius: Int(mapView.currentRadiusKm))
    }
}

extension LGMapView: LGMapDetailViewDelegate {
    func mapDetailTapped(_ listing: Listing, originImageView: UIImageView?) {
        delegate?.detailTapped(listing, originImageView: originImageView)
    }
}

extension LGMapView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension LGMapView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: LGMapAnnotation.reusableID)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: LGMapAnnotation.reusableID)
        } else {
            anView?.annotation = annotation
        }
        
        anView?.image = (annotation as? LGMapAnnotation)?.icon
        return anView
    }
    
}

protocol LGMapRetryViewDelegate: class {
    func retryTapped()
}

final class LGMapRetryView: UIView {
    private let disposeBag = DisposeBag()
    let isLoading = Variable(false)
    weak var delegate: LGMapRetryViewDelegate?
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setupRx()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.setTitleColor(.lgBlack, for: .normal)
        button.setTitle(LGLocalizedString.listingMapRedoSearch, for: .normal)
        button.titleLabel?.font = UIFont.systemMediumFont(size: 16)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.contentEdgeInsets = UIEdgeInsetsMake(0, Metrics.bigMargin, 0, Metrics.bigMargin)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.color = .lgBlack
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private func setupUI() {
        
        retryButton.addTarget(self, action: #selector(retryButtonPressed), for: .touchUpInside)
        
        backgroundColor = .white
        
        cornerRadius = LGMapViewMetrics.retryButtonHeight/2
        applyShadow(withOpacity: 0.12, radius: 8.0)
        
        addSubviewsForAutoLayout([retryButton, loadingIndicator])
        
        loadingIndicator.layout(with: self).center()
        retryButton.layout(with: self).center()
    }
    
    private func setupRx() {
        isLoading
            .asDriver()
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
                self?.retryButton.isHidden = isLoading
            }).disposed(by: disposeBag)
    }
    
    @objc private func retryButtonPressed() {
        delegate?.retryTapped()
    }
    
    override var intrinsicContentSize: CGSize {
        let width = retryButton.intrinsicContentSize.width +  2*Metrics.bigMargin
        return CGSize(width: min(width, LGMapViewMetrics.retryViewMinimunWidth), height: LGMapViewMetrics.messageViewHeight)
    }
    
}

final class LGMapMessageView: UIView {
    private let disposeBag = DisposeBag()
    private let mapMessage: Driver<String>
    private let mapMessageVariable = Variable("")
    
    init() {
        self.mapMessage = mapMessageVariable.asDriver()
        super.init(frame: .zero)
        setupUI()
        setupRx()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private let mapMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textAlignment = .center
        label.font = LGMapViewMetrics.mapMessageFont
        return label
    }()
    
    private func setupUI() {
        backgroundColor = .white
        addSubviewsForAutoLayout([mapMessageLabel])
        mapMessageLabel.layout(with: self).fill(by: Metrics.margin)
    }
    
    private func setupRx() {
        mapMessage.asObservable()
            .bind(to: mapMessageLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    public func updateMessage(with text: String) {
        mapMessageVariable.value = text
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: LGMapViewMetrics.messageViewWidth, height: LGMapViewMetrics.messageViewHeight)
    }
    
}

private struct LGMapViewMetrics {
    static let gpsButtonCornerRadius: CGFloat = 10
    static let gpsIconSize: CGSize = CGSize(width: 50, height: 50)
    static let messageRadius: CGFloat = 6
    static let mapMessageFont = UIFont.systemFont(size: 16)
    static let messageViewHeight: CGFloat = 80
    static let messageViewWidth: CGFloat = 340
    static let retryButtonHeight: CGFloat = 30
    static let retryButtonMarginError: CGFloat = 40
    static let retryViewMinimunWidth: CGFloat = 200
}
