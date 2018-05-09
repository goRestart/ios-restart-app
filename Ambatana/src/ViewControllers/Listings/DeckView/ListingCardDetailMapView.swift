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
    func didTapOnMapSnapshot(_ snapshot: UIView)
}

final class ListingCardDetailMapView: UIView {
    private struct Layout {
        struct Defaults {
            static let insets = UIEdgeInsets(top: Metrics.margin, left: Metrics.veryShortMargin,
                                             bottom: Metrics.margin, right: Metrics.veryShortMargin)
            
        }
        struct CornerRadius { static let map: CGFloat = LGUIKitConstants.bigCornerRadius }
    }
    private var showExactLocationOnMap: Bool = false

    private let verticalStackView = UIStackView()

    private let mapHeader = UIStackView()
    private let locationLabel = UILabel()
    private let mapPlaceHolder = UIView()

    let mapSnapShotView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Layout.CornerRadius.map
        return imageView
    }()

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
        cleanSnapshot()
        MKMapView.snapshotAt(region, size: size, with: { [weak self] (snapshot, error) in
            guard error == nil, let image = snapshot?.image else { return }
            self?.mapSnapShotView.image = image
            self?.mapSnapShotView.layer.add(CATransition(), forKey: kCATransition)
        })
        self.showExactLocationOnMap = showExactLocationOnMap

        if showExactLocationOnMap {
            let mapPin = UIImageView(image: #imageLiteral(resourceName: "map_pin"))
            mapPin.contentMode = .scaleAspectFit
            mapSnapShotView.addSubviewForAutoLayout(mapPin)
            mapPin.layout()
                .height(LGUIKitConstants.mapPinHeight)
                .width(LGUIKitConstants.mapPinWidth)
            mapPin.layout(with: mapSnapShotView).center()
        }
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
        mapSnapShotView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8)
        verticalStackView.addArrangedSubview(mapSnapShotView)
        mapSnapShotView.backgroundColor = .gray
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        gesture.cancelsTouchesInView = true
        addGestureRecognizer(gesture)
        verticalStackView.addArrangedSubview(mapSnapShotView)
    }

    @objc private func tapOnView() {
        delegate?.didTapOnMapSnapshot(mapSnapShotView)
    }

    private func cleanSnapshot() {
        mapSnapShotView.subviews.forEach { subView in
            subView.removeFromSuperview()
        }
    }
}
