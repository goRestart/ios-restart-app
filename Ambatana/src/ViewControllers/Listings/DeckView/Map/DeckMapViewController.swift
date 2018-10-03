import Foundation
import MapKit
import LGComponents

protocol DeckMapViewDelegate: class {
    func close(_ vc: DeckMapViewController)
}

struct DeckMapData {
    let location: CLLocationCoordinate2D
    let shouldHighlightCenter: Bool
}

final class DeckMapViewController: UIViewController {
    private enum Constants {
        static let pinID = "mapPin"
        static let circleRadius: CLLocationDistance = 1000.0
        static let regionSpan = MKCoordinateSpanMake(0.1, 0.1)
    }

    private enum Layout {
        static let buttonSize = CGSize(width: 40, height: 40)
    }

    private let annotation = MKPointAnnotation()
    private var shouldShowAnnotation: Bool = false
    private let overlay: MKCircle

    private var mapView: MKMapView { return deckMapView.mapView }

    let deckMapView: DeckMapView
    weak var delegate: DeckMapViewDelegate?

    init(with deckMapData: DeckMapData) {
        self.deckMapView = DeckMapView()
        self.overlay = MKCircle(center: deckMapData.location, radius: Constants.circleRadius)
        self.annotation.coordinate = deckMapData.location
        self.shouldShowAnnotation = deckMapData.shouldHighlightCenter
        super.init(nibName: nil, bundle: nil)
        let region = MKCoordinateRegion(center: deckMapData.location, span: Constants.regionSpan)
        self.mapView.setRegion(region, animated: false)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func loadView() { self.view = deckMapView }

    override func viewDidLoad() {
        super.viewDidLoad()
        purgeLocationDataForMapSingleton()
        mapView.delegate = self

        mapView.add(overlay)

        guard shouldShowAnnotation else { return }
        mapView.addAnnotation(annotation)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLeftCloseButton()
    }

    private func purgeLocationDataForMapSingleton() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
    }

    private func setLeftCloseButton() {
        let button = UIButton(type: .custom)
        deckMapView.addSubviewForAutoLayout(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: deckMapView.topAnchor, constant: statusBarHeight + Metrics.shortMargin),
            button.leadingAnchor.constraint(equalTo: deckMapView.leadingAnchor, constant: Metrics.veryShortMargin),
            button.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            button.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width)
        ])
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        button.setImage(R.Asset.IconsButtons.icCloseCarousel.image, for: .normal)
    }

    @objc private func closeView() {
        delegate?.close(self)
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
