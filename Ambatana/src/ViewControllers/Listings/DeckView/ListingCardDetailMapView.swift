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
        struct CornerRadius { static let mapView: CGFloat = 6.0 }
    }

    private var region: MKCoordinateRegion?
    private var tap: UITapGestureRecognizer?

    let mapView = MKMapView.sharedInstance
    let mapSnapShotView = UIImageView()
    weak var delegate: ListingCardDetailMapViewDelegate?

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setRegion(_ region: MKCoordinateRegion, size: CGSize) {
        MKMapView.snapshotAt(region, size: size, with: { (snapshot, error) in
            guard error == nil, let image = snapshot?.image else { return }
            self.mapSnapShotView.image = image
        })
        mapView.setRegion(region, animated: false)
        self.region = region
    }

    func showRegion(_ region: MKCoordinateRegion, animated: Bool) {
        mapView.setRegion(region, animated: animated)
        setupMap()
        self.region = region
    }

    func showRegion(animated: Bool) {
        guard let region = self.region else { return }
        mapView.setCenter(region.center, animated: animated)
        setupMap()
    }

    private func setupUI() {
        setupSnapshotView()
    }

    private func setupSnapshotView() {
        mapSnapShotView.contentMode = .scaleAspectFill
        mapSnapShotView.clipsToBounds = true
        mapSnapShotView.cornerRadius = Layout.CornerRadius.mapView

        mapSnapShotView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mapSnapShotView)

        mapSnapShotView.layout(with: self).fillVertical(by: Layout.Defaults.insets.top)
        let mapViewConstraints = [
            mapSnapShotView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.Defaults.insets.top),
            mapSnapShotView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.Defaults.insets.top)
        ]
        mapSnapShotView.backgroundColor = .gray

        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        self.addGestureRecognizer(gesture)
        tap = gesture

        NSLayoutConstraint.activate(mapViewConstraints)
    }

    private func setupMap() {
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0)
        mapView.delegate = self
        addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        let mapViewConstraints = [
            mapView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.Defaults.insets.top),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.Defaults.insets.right),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.Defaults.insets.bottom),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.Defaults.insets.left)
        ]
        NSLayoutConstraint.activate(mapViewConstraints)
    }

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        guard fullyRendered else {
            hideMap()
            return
        }
        showMap()
    }

    @objc private func tapOnView() {
        guard mapView.superview != nil else {
            delegate?.didTapOnMapSnapshot(mapSnapShotView)
            return
        }
        delegate?.didTapMapView()
    }


    private func showMap() {
        UIView.animate(withDuration: 0.3,
                       animations: { [weak self] in
                        self?.mapView.alpha = 1
                        self?.mapSnapShotView.alpha = 0
                        self?.mapView.layoutIfNeeded()
        })
    }

    func hideMap(animated: Bool) {
        guard animated else {
            hideMap()
            mapView.removeFromSuperview()
            return
        }
        UIView.animate(withDuration: 0.3,
                       animations: { [weak self] in
                        self?.hideMap()
            }, completion: { completion in
                self.mapView.removeFromSuperview()
        })
    }

    private func hideMap() {
        mapView.alpha = 0
        mapSnapShotView.alpha = 1
    }
}
