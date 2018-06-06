import Foundation
import MapKit
import LGComponents

protocol DeckMapViewDelegate: class {
    func deckMapViewDidTapOnView(_ vc: DeckMapViewController)
}

struct DeckMapData {
    let size: CGSize
    let location: CLLocationCoordinate2D
    let shouldHighlightCenter: Bool
}

final class DeckMapViewController: UIViewController {
    private struct Constants {
        static let pinID = "mapPin"
        static let circleRadius: CLLocationDistance = 1000.0
        static let regionSpan = MKCoordinateSpanMake(0.1, 0.1)
    }

    private let annotation = MKPointAnnotation()
    private var shouldShowAnnotation: Bool = false
    private let overlay: MKCircle

    private var mapView: MKMapView { return deckMapView.mapView }
    private var blurView: UIVisualEffectView { return deckMapView.visualEffect }

    let deckMapView: DeckMapView
    weak var delegate: DeckMapViewDelegate?

    init(with deckMapData: DeckMapData) {
        self.deckMapView = DeckMapView(withSize: deckMapData.size)
        self.overlay = MKCircle(center: deckMapData.location, radius: Constants.circleRadius)
        self.annotation.coordinate = deckMapData.location
        self.shouldShowAnnotation = deckMapData.shouldHighlightCenter
        super.init(nibName: nil, bundle: nil)
        let region = MKCoordinateRegion(center: deckMapData.location, span: Constants.regionSpan)
        self.mapView.setRegion(region, animated: false)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func loadView() { self.view = deckMapView }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blurView.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 0.9
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        purgeLocationDataForMapSingleton()
        mapView.delegate = self

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(informDelegate)))
        mapView.add(overlay)

        guard shouldShowAnnotation else { return }
        mapView.addAnnotation(annotation)
    }

    @objc private func informDelegate() {
        delegate?.deckMapViewDidTapOnView(self)
    }

    private func purgeLocationDataForMapSingleton() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
    }
}

// MARK: MapViewDelegate
extension DeckMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circle = overlay as? MKCircle else { return MKCircleRenderer() }
        let renderer = MKCircleRenderer(overlay: circle)
        renderer.fillColor = UIColor(red: 0, green: 0, blue: 0).withAlphaComponent(0.1)
        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let mapPinView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.pinID) else {
            let newMapPinView = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.pinID)
            newMapPinView.image = R.Asset.IconsButtons.Map.mapPin.image
            return newMapPinView
        }
        mapPinView.annotation = annotation
        return mapPinView
    }
}
