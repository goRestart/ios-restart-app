//
//  MapZoomHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 03/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import MapKit


/*
 Blocks map zoomin when it passes certain lat and lon deltas. It uses the proxy-delegate pattern as it sets itself as the
 mapview delegate. When using MapZoomBlocker the MKMapViewDelegate must be set to the MapZoomBlocker instead of the MKMapView
 */
class MapZoomBlocker: NSObject, MKMapViewDelegate {

    private var mapZoomTimer: Timer?
    private let minLongitudeDelta: CLLocationDegrees
    private let minLatitudeDelta: CLLocationDegrees
    private var isResettingRegion: Bool = false

    weak var delegate: MKMapViewDelegate?
    weak var mapView: MKMapView?

    init(mapView: MKMapView, minLatDelta: CLLocationDegrees, minLonDelta: CLLocationDegrees) {
        self.mapView = mapView
        minLongitudeDelta = minLonDelta
        minLatitudeDelta = minLatDelta
        super.init()

        mapView.delegate = self
    }

    func stop() {
        mapZoomTimer?.invalidate()
    }


    // MARK: - Delegate

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        delegate?.mapView?(mapView, regionWillChangeAnimated: animated)

        mapZoomTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(resetRegionDelta),
                                                              userInfo: nil, repeats: true)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        delegate?.mapView?(mapView, regionDidChangeAnimated: animated)

        mapZoomTimer?.invalidate()
        resetRegionDelta()
        isResettingRegion = false
    }

    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        delegate?.mapViewWillStartLoadingMap?(mapView)
    }
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        delegate?.mapViewDidFinishLoadingMap?(mapView)
    }
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        delegate?.mapViewDidFailLoadingMap?(mapView, withError: error)
    }
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        delegate?.mapViewWillStartRenderingMap?(mapView)
    }
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        delegate?.mapViewDidFinishRenderingMap?(mapView, fullyRendered: fullyRendered)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return delegate?.mapView?(mapView, viewFor: annotation)
    }
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        delegate?.mapView?(mapView, didAdd: views)
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        delegate?.mapView?(mapView, annotationView: view, calloutAccessoryControlTapped: control)
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        delegate?.mapView?(mapView, didSelect: view)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        delegate?.mapView?(mapView, didDeselect: view)
    }
    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        delegate?.mapViewWillStartLocatingUser?(mapView)
    }
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        delegate?.mapViewDidStopLocatingUser?(mapView)
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        delegate?.mapView?(mapView, didUpdate: userLocation)
    }
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        delegate?.mapView?(mapView, didFailToLocateUserWithError: error)
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        delegate?.mapView?(mapView, annotationView: view, didChange: newState, fromOldState: oldState)
    }
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        delegate?.mapView?(mapView, didChange: mode, animated: animated)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return delegate?.mapView?(mapView, rendererFor: overlay) ?? MKOverlayRenderer()
    }
    func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
        delegate?.mapView?(mapView, didAdd: renderers)
    }


    // MARK: - Limit zoom in

    /**
     If the user did try to zoom in more than allowed, reset the region span to the original one.
     If the view is already resetting, this func will just return.
     The reset will be animated.
     This will also reset any rotation in the map.
     */
    func resetRegionDelta() {
        guard let mapView = mapView else { return }
        guard !isResettingRegion else { return }
        guard shouldForceResetMapRegion() else { return }

        let newRegion = resetRegion(mapView.region)
        mapView.setRegion(newRegion, animated: true)
        isResettingRegion = true
    }

    /**
     Calculate whether or not the MapRegion should be resetted according to the current Span and the minimum allowed
     */
    func shouldForceResetMapRegion() -> Bool {
        guard let mapView = mapView else { return false }
        let mapLat = mapView.region.span.latitudeDelta
        let mapLon = mapView.region.span.longitudeDelta
        return mapLat < minLatitudeDelta || mapLon < minLongitudeDelta
    }

    /**
     Given a MKCoordinateRegion, creates a new one with the `span` resetted to the allowed minimum deltas.
     */
    func resetRegion(_ region: MKCoordinateRegion) -> MKCoordinateRegion {
        var newRegion = region
        newRegion.span.latitudeDelta = minLatitudeDelta
        newRegion.span.longitudeDelta = minLongitudeDelta
        return newRegion
    }

}
