import LGComponents
import LGCoreKit
import MapKit

final class CellMapViewer: NSObject, MKMapViewDelegate {

    var mapContainer: UIView = UIView()

    func openMapOnView(mainView: UIView,
                       fromInitialView initialView: UIView,
                       withCenterCoordinates coordinates: LGLocationCoordinates2D) {

        let clCoordinates = coordinates.coordinates2DfromLocation()
        guard CLLocationCoordinate2DIsValid(clCoordinates) else { return }

        let mapView = MKMapView()

        mapView.delegate = self
        mapView.setCenter(clCoordinates, animated: true)

        mapView.layer.cornerRadius = 20.0

        let region = MKCoordinateRegionMakeWithDistance(clCoordinates,
                                                        SharedConstants.accurateRegionRadius*2,
                                                        SharedConstants.accurateRegionRadius*2)
        mapView.setRegion(region, animated: true)

        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = true

        let mapOverlay: MKOverlay = MKCircle(center:clCoordinates,
                                             radius: 300)

        mapView.add(mapOverlay)

        let effect = UIBlurEffect(style: .dark)
        let mapBgBlurEffect = UIVisualEffectView(effect: effect)

        mapContainer.alpha = 0.0

        let mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(mapTap)
        mapBgBlurEffect.addGestureRecognizer(mapTap)

        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        mapBgBlurEffect.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false

        mainView.addSubview(mapContainer)

        mapContainer.layout(with: mainView).fill()

        mapContainer.addSubview(mapBgBlurEffect)
        mapBgBlurEffect.layout(with: mapContainer).fill()

        mapContainer.addSubview(mapView)

        mapView.layout().height(300).widthProportionalToHeight()
        mapView.layout(with: mapContainer).center()

        // we want to make the full map appear from the map position in the cell
        mapContainer.frame = initialView.convertToWindow(initialView.frame)

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.mapContainer.alpha = 1.0
            mainView.layoutIfNeeded()
        }
    }

    @objc func mapTapped() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mapContainer.alpha = 0.0
        }) { [weak self] _ in
            self?.mapContainer.subviews.forEach { subview in
                subview.removeFromSuperview()
            }
            self?.mapContainer.removeFromSuperview()
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
            return renderer
        }
        return MKCircleRenderer()
    }
}
