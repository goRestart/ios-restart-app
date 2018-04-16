//
//  ListingCardDetailMapView.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//
import Foundation
import MapKit

protocol ListingCardDetailMapViewDelegate: class {
    func didTapMapView()
    func didTapOnMapSnapshot(_ snapshot: UIView)
}

final class ListingCardDetailMapView: UIView, MKMapViewDelegate {
    private struct Layout {
        struct Defaults {
            static let insets = UIEdgeInsets(top: Metrics.margin, left: Metrics.margin,
                                             bottom: Metrics.margin, right: Metrics.margin)
            
        }
        struct CornerRadius { static let map: CGFloat = LGUIKitConstants.bigCornerRadius }
    }
    private static let mapPinAnnotationReuseId = "mapPin"

    private var region: MKCoordinateRegion?
    private var tapGesture: UITapGestureRecognizer?
    private var showExactLocationOnMap: Bool = false

    private let verticalStackView = UIStackView()

    private let mapHeader = UIStackView()
    private let locationLabel = UILabel()
    private let mapPlaceHolder = UIView()

    private var mapView: MKMapView { return MKMapView.sharedInstance }
    private(set) var fullMapConstraints: [NSLayoutConstraint] = []

    let mapSnapShotView = UIImageView()
    var isExpanded: Bool = false

    weak var delegate: ListingCardDetailMapViewDelegate?

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setLocationName(_ name: String?) {
        locationLabel.text = name
        locationLabel.isHidden = name == nil
        mapHeader.isHidden = name == nil
    }

    func setRegion(_ region: MKCoordinateRegion, size: CGSize, showExactLocationOnMap: Bool) {
        MKMapView.snapshotAt(region, size: size, with: { [weak self] (snapshot, error) in
            guard error == nil, let image = snapshot?.image else { return }
            self?.mapSnapShotView.image = image
            self?.mapSnapShotView.layer.add(CATransition(), forKey: kCATransition)
        })
        mapView.setRegion(region, animated: false)
        self.region = region
        self.showExactLocationOnMap = showExactLocationOnMap

        if showExactLocationOnMap {
            let mapPin = UIImageView(image: #imageLiteral(resourceName: "map_pin"))
            mapPin.contentMode = .scaleAspectFit
            mapSnapShotView.addSubviewForAutoLayout(mapPin)
            mapPin.layout().height(37).width(26)
            mapPin.layout(with: mapSnapShotView).center()
        }
    }

    func showRegion(animated: Bool) {
        guard let region = self.region else { return }
        setupMap()
        guard mapView.region.center != region.center else {
            showMap()
            return
        }
        mapView.setCenter(region.center, animated: animated)
    }

    private func setupUI() {
        setupStackView()
        setupMapHeader()
        setupSnapshotView()
    }

    private func setupStackView() {
        addSubviewForAutoLayout(verticalStackView)
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillProportionally
        verticalStackView.spacing = Metrics.margin
        verticalStackView.layout(with: self)
            .fillHorizontal(by: Layout.Defaults.insets.left)
            .fillVertical()
    }

    private func setupLocationLabel() {
        locationLabel.font = UIFont.systemMediumFont(size: 13)
        locationLabel.textAlignment = .left
        locationLabel.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
        locationLabel.backgroundColor = UIColor.clear
        locationLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    func setupMapHeader() {
        mapHeader.axis = .horizontal
        mapHeader.distribution = .fillProportionally
        
        let location = UIImageView(image: #imageLiteral(resourceName: "nit_location"))
        location.contentMode = .center
        location.backgroundColor = UIColor.clear
        location.widthAnchor.constraint(equalToConstant: 16).isActive = true

        setupLocationLabel()

        mapHeader.addArrangedSubview(location)
        mapHeader.addArrangedSubview(locationLabel)

        verticalStackView.addArrangedSubview(mapHeader)
    }

    private func setupSnapshotView() {
        mapSnapShotView.contentMode = .scaleAspectFill
        mapSnapShotView.clipsToBounds = true
        mapSnapShotView.layer.cornerRadius = Layout.CornerRadius.map
        mapSnapShotView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8)
        verticalStackView.addArrangedSubview(mapSnapShotView)
        mapSnapShotView.backgroundColor = .gray
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        gesture.cancelsTouchesInView = true
        addGestureRecognizer(gesture)
        tapGesture = gesture
        verticalStackView.addArrangedSubview(mapSnapShotView)
    }

    private func setupMap() {
        backgroundColor = UIColor.white
        mapView.delegate = self
        addSubviewForAutoLayout(mapView)
        fullMapConstraints = [
            mapView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.Defaults.insets.top),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.Defaults.insets.right),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.Defaults.insets.bottom),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.Defaults.insets.left)
        ]
        isExpanded = true

        NSLayoutConstraint.activate(fullMapConstraints)
        showMap()
    }

    @objc private func tapOnView() {
        guard isExpanded else {
            tapGesture?.isEnabled = false
            delegate?.didTapOnMapSnapshot(mapSnapShotView)
            return
        }
        delegate?.didTapMapView()
    }


    private func showMap() {
        if let center = region?.center {
            purgeLocationArea()
            if showExactLocationOnMap {
                let mapPinAnnotation = MKPointAnnotation()
                mapPinAnnotation.coordinate = center
                mapView.addAnnotation(mapPinAnnotation)
            } else {
                let overlay = MKCircle(center: center, radius: Constants.accurateRegionRadius)
                mapView.add(overlay)
            }

        }
        bringSubview(toFront: mapView)
        UIView.animate(withDuration: 0.3,
                       animations: { [weak self] in
                        self?.mapView.alpha = 1
                        self?.mapSnapShotView.alpha = 0
                        self?.mapView.cornerRadius = Layout.CornerRadius.map
            }, completion: { [weak self] completion in
                guard let strongSelf = self else { return }
                strongSelf.tapGesture?.isEnabled = true
        })
    }

    func hideMap(animated: Bool) {
        purgeLocationArea()
        tapGesture?.isEnabled = false
        isExpanded = false
        guard animated else {
            hideMap()
            tapGesture?.isEnabled = true
            return
        }
        UIView.animate(withDuration: 0.3,
                       animations: { [weak self] in
                        self?.hideMap()
            }, completion: { [weak self] completion in
                self?.tapGesture?.isEnabled = true
        })
    }

    private func hideMap() {
        mapView.alpha = 0
        mapSnapShotView.alpha = 1
        bringSubview(toFront: verticalStackView)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circle = overlay as? MKCircle else { return MKCircleRenderer() }
        let renderer = MKCircleRenderer(overlay: circle)
        renderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let mapPinView = mapView.dequeueReusableAnnotationView(withIdentifier: ListingCardDetailMapView.mapPinAnnotationReuseId) else {
            let newMapPinView = MKAnnotationView(annotation: annotation,
                                                 reuseIdentifier: ListingCardDetailMapView.mapPinAnnotationReuseId)
            newMapPinView.image = #imageLiteral(resourceName: "map_pin")
            return newMapPinView
        }
        mapPinView.annotation = annotation
        return mapPinView
    }

    private func purgeLocationArea() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
    }

}
