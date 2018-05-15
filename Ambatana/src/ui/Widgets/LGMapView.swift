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

protocol LGMapViewDelegate: class {
    func gpsButtonTapped()
}

final class LGMapView: UIView {
    
    weak var delegate: LGMapViewDelegate?
    
    // MARK: - Subviews
    
    private let mapView: MKMapView = MKMapView()
    
    private let gpsLocationButton: UIButton = {
        let button = UIButton()
        button.cornerRadius = LGMapViewMetrics.gpsButtonCornerRadius
        button.setImage(#imageLiteral(resourceName: "map_user_location_button"), for: .normal)
        return button
    }()

    // MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //  MARK: - Private
    
    private func setupUI() {
        gpsLocationButton.addTarget(self, action: #selector(gpsButtonPressed), for: .touchUpInside)
        
        addSubviewsForAutoLayout([mapView, gpsLocationButton])
        
        mapView.layout(with: self).fill()
        gpsLocationButton.layout(with: self).below(by: Metrics.shortMargin).right()
        gpsLocationButton.layout().height(LGMapViewMetrics.gpsIconSize.height).width(LGMapViewMetrics.gpsIconSize.width)
    }
    
    //  MARK: - Public
    
    func updateMapRegion(location: LGLocationCoordinates2D?) {
        guard let region = location?.region(radiusAccuracy: Constants.accurateRegionRadius) else { return }
        mapView.setRegion(region, animated: false)
    }
    
    //  MARK: - Actions
    
    @objc private func gpsButtonPressed() {
        delegate?.gpsButtonTapped()
    }
}

private struct LGMapViewMetrics {
    static let gpsButtonCornerRadius: CGFloat = 10
    static let gpsIconSize: CGSize = CGSize(width: 50, height: 50)
}
