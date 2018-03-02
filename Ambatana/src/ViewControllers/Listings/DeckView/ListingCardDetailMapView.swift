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
        struct Height { static let snapshot: CGFloat = 100.0 }
        struct Defaults {
            static let insets = UIEdgeInsets(top: Metrics.margin, left: Metrics.margin,
                                             bottom: Metrics.margin, right: Metrics.margin)
            
        }
        struct CornerRadius { static let map: CGFloat = LGUIKitConstants.bigCornerRadius }
    }

    private var region: MKCoordinateRegion?
    private var tapGesture: UITapGestureRecognizer?

    private let verticalStackView = UIStackView()

    private let mapHeader = UIStackView()
    private let locationLabel = UILabel()
    private let mapPlaceHolder = UIView()

    private lazy var mapView = MKMapView.sharedInstance
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
        mapHeader.isHidden = name == nil
    }

    func setRegion(_ region: MKCoordinateRegion, size: CGSize) {
        MKMapView.snapshotAt(region, size: size, with: { [weak self] (snapshot, error) in
            guard error == nil, let image = snapshot?.image else { return }
            self?.mapSnapShotView.image = image
            self?.mapSnapShotView.layer.add(CATransition(), forKey: kCATransition)
        })
        mapView.setRegion(region, animated: false)
        self.region = region
    }

    func showRegion(_ region: MKCoordinateRegion, animated: Bool) {
        setupMap()
        mapView.setRegion(region, animated: animated)
        self.region = region
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
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillProportionally
        verticalStackView.spacing = Metrics.margin
        addSubview(verticalStackView)
        verticalStackView.layout(with: self)
            .fillHorizontal(by: Layout.Defaults.insets.left).fillVertical(by: Layout.Defaults.insets.top)
    }

    private func setupLocationLabel() {
        locationLabel.font = UIFont.systemMediumFont(size: 13)
        locationLabel.textAlignment = .left
        locationLabel.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
        locationLabel.backgroundColor = UIColor.white

        locationLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        locationLabel.setContentHuggingPriority(.required, for: .vertical)
    }
    func setupMapHeader() {
        mapHeader.translatesAutoresizingMaskIntoConstraints = false
        mapHeader.axis = .horizontal
        mapHeader.distribution = .fillProportionally
        mapHeader.setContentCompressionResistancePriority(.required, for: .vertical)
        mapHeader.backgroundColor = UIColor.white

        let location = UIImageView(image: #imageLiteral(resourceName: "nit_location"))
        location.contentMode = .center
        location.layout().width(16)
        location.backgroundColor = UIColor.white

        setupLocationLabel()

        mapHeader.addArrangedSubview(location)
        mapHeader.addArrangedSubview(locationLabel)

        verticalStackView.addArrangedSubview(mapHeader)
    }

    private func setupSnapshotView() {
        mapSnapShotView.contentMode = .scaleAspectFill
        mapSnapShotView.clipsToBounds = true
        mapSnapShotView.layer.cornerRadius = Layout.CornerRadius.map
        mapSnapShotView.translatesAutoresizingMaskIntoConstraints = false
        let height = mapSnapShotView.heightAnchor.constraint(equalToConstant: Layout.Height.snapshot)
        height.priority = .required - 1
        height.isActive = true
        verticalStackView.addArrangedSubview(mapSnapShotView)
        mapSnapShotView.backgroundColor = .gray
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        self.addGestureRecognizer(gesture)
        tapGesture = gesture
        verticalStackView.addArrangedSubview(mapSnapShotView)
    }

    private func setupMap() {
        backgroundColor = UIColor.white
        mapView.delegate = self
        addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
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

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        guard fullyRendered else {
            hideMap()
            return
        }
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
        bringSubview(toFront: mapView)
        UIView.animate(withDuration: 0.3,
                       animations: { [weak self] in
                        self?.mapView.alpha = 1
                        self?.mapSnapShotView.alpha = 0
                        self?.mapView.cornerRadius = Layout.CornerRadius.map
            }, completion: { [weak self] completion in
                guard let strongSelf = self, let mapView = self?.mapView else { return }
                strongSelf.bringSubview(toFront: mapView)
                strongSelf.tapGesture?.isEnabled = true
        })
    }

    func hideMap(animated: Bool) {
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

}
