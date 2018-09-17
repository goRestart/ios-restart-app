import Foundation
import MapKit

final class DeckMapView: UIView {
    let mapView: MKMapView

    convenience init() {
        self.init(mapView: MKMapView.sharedInstance)
    }

    private init(mapView: MKMapView) {
        self.mapView = mapView
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    private func setupUI() {
        addSubviewForAutoLayout(mapView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
}
