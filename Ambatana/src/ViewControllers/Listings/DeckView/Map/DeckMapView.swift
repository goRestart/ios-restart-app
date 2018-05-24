//
//  DeckMapView.swift
//  LetGo
//
//  Created by Facundo Menzella on 03/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import MapKit

final class DeckMapView: UIView {

    let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let mapView: MKMapView

    convenience init(withSize size: CGSize) {
        self.init(withSize: size, mapView: MKMapView.sharedInstance)
    }

    private init(withSize size: CGSize, mapView: MKMapView) {
        self.mapView = mapView
        super.init(frame: .zero)
        setupUI(withMapSize: size)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    private func setupUI(withMapSize size: CGSize) {
        addSubviewsForAutoLayout([visualEffect, mapView])
        setupConstraints(withMapSize: size)
        mapView.layer.cornerRadius = 16
    }

    private func setupConstraints(withMapSize size: CGSize) {
        NSLayoutConstraint.activate([
            visualEffect.topAnchor.constraint(equalTo: topAnchor),
            visualEffect.rightAnchor.constraint(equalTo: rightAnchor),
            visualEffect.bottomAnchor.constraint(equalTo: bottomAnchor),
            visualEffect.leftAnchor.constraint(equalTo: leftAnchor),

            mapView.widthAnchor.constraint(equalToConstant: size.width),
            mapView.heightAnchor.constraint(equalToConstant: size.height),
            mapView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mapView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
}
