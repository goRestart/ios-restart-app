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
}

final class LGMapView: UIView {
    
    private let disposeBag = DisposeBag()
    
    let mkAnnotationsVariable: Variable<[MKAnnotation]?> = Variable(nil)
    
    weak var delegate: LGMapViewDelegate?
    
    // MARK: - Subviews
    
    private let mapView = MKMapView.sharedInstance
    
    private let gpsLocationButton: UIButton = {
        let button = UIButton()
        button.cornerRadius = LGMapViewMetrics.gpsButtonCornerRadius
        button.setImage(#imageLiteral(resourceName: "map_user_location_button"), for: .normal)
        return button
    }()
    
    private let mapMessageView: LGMapMessageView = {
        let view = LGMapMessageView()
        view.backgroundColor = .white
        view.alpha = 0
        view.cornerRadius = LGMapViewMetrics.messageRadius
        view.applyDefaultShadow()
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
        
        addSubviewsForAutoLayout([mapView, mapMessageView, gpsLocationButton])
        
        mapView.layout(with: self).fill()
        mapMessageView.layout(with: self).fillHorizontal(by: Metrics.margin).top(by: Metrics.margin)
        
        gpsLocationButton.layout(with: self).below(by: Metrics.shortMargin).right()
        gpsLocationButton.layout().height(LGMapViewMetrics.gpsIconSize.height).width(LGMapViewMetrics.gpsIconSize.width)
    }
    
    private func setupRx() {
        mkAnnotationsVariable.asDriver()
            .drive(onNext: { [weak self] annotations in
                guard let annotations = annotations else { return }
                let alphaValue: CGFloat = annotations.isEmpty ? 1 : 0
                self?.mapMessageView.animateTo(alpha: alphaValue)
            }).disposed(by: disposeBag)
        mkAnnotationsVariable.asObservable()
            .map { $0 ?? [] }
            .bind(to: mapView.rx.annotations)
            .disposed(by: disposeBag)
        mapView.rx.didSelectAnnotationView
            .subscribe(onNext: { [weak self] annotationView in
                guard let lgAnnotationView = annotationView.annotation as? LGMapAnnotation else { return }
                annotationView.image = lgAnnotationView.selectedAnnotation
                self?.updateMapRegion(location: lgAnnotationView.location, animated: true)
            }).disposed(by: disposeBag)
        mapView.rx.didDeselectAnnotationView
            .subscribe(onNext: { annotationView in
                guard let lgAnnotationView = annotationView.annotation as? LGMapAnnotation else { return }
                annotationView.image = lgAnnotationView.deselectedAnnotation
            }).disposed(by: disposeBag)
    }
    
    private func showNoResultMessage() {
        mapMessageView.mapMessageVariable.value = LGLocalizedString.listingsMapNoResultsMessage
    }
    
    //  MARK: - Public
    
    func updateMapRegion(location: LGLocationCoordinates2D?, animated: Bool = false) {
        guard let region = location?.region(radiusAccuracy: Constants.accurateRegionRadius) else { return }
        mapView.setRegion(region, animated: animated)
    }
    
    func update(annotations: [MKAnnotation]) {
        if annotations.isEmpty {
            showNoResultMessage()
        } else {
            mkAnnotationsVariable.value = annotations
        }
    }
    
    //  MARK: - Actions
    
    @objc private func gpsButtonPressed() {
        delegate?.gpsButtonTapped()
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

final class LGMapMessageView: UIView {
    private let disposeBag = DisposeBag()
    let mapMessageVariable = Variable("")
    
    init() {
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
        mapMessageVariable
            .asObservable()
            .bind(to: mapMessageLabel.rx.text)
            .disposed(by: disposeBag)
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
}


