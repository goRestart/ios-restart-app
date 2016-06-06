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

    private var mapZoomTimer: NSTimer?
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

    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        delegate?.mapView?(mapView, regionWillChangeAnimated: animated)

        mapZoomTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(resetRegionDelta),
                                                              userInfo: nil, repeats: true)
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        delegate?.mapView?(mapView, regionDidChangeAnimated: animated)

        mapZoomTimer?.invalidate()
        resetRegionDelta()
        isResettingRegion = false
    }

    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        delegate?.mapViewWillStartLoadingMap?(mapView)
    }
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        delegate?.mapViewDidFinishLoadingMap?(mapView)
    }
    func mapViewDidFailLoadingMap(mapView: MKMapView, withError error: NSError) {
        delegate?.mapViewDidFailLoadingMap?(mapView, withError: error)
    }
    func mapViewWillStartRenderingMap(mapView: MKMapView) {
        delegate?.mapViewWillStartRenderingMap?(mapView)
    }
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        delegate?.mapViewDidFinishRenderingMap?(mapView, fullyRendered: fullyRendered)
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        return delegate?.mapView?(mapView, viewForAnnotation: annotation)
    }
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        delegate?.mapView?(mapView, didAddAnnotationViews: views)
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        delegate?.mapView?(mapView, annotationView: view, calloutAccessoryControlTapped: control)
    }
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        delegate?.mapView?(mapView, didSelectAnnotationView: view)
    }
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        delegate?.mapView?(mapView, didDeselectAnnotationView: view)
    }
    func mapViewWillStartLocatingUser(mapView: MKMapView) {
        delegate?.mapViewWillStartLocatingUser?(mapView)
    }
    func mapViewDidStopLocatingUser(mapView: MKMapView) {
        delegate?.mapViewDidStopLocatingUser?(mapView)
    }
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        delegate?.mapView?(mapView, didUpdateUserLocation: userLocation)
    }
    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        delegate?.mapView?(mapView, didFailToLocateUserWithError: error)
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        delegate?.mapView?(mapView, annotationView: view, didChangeDragState: newState, fromOldState: oldState)
    }
    func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        delegate?.mapView?(mapView, didChangeUserTrackingMode: mode, animated: animated)
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return delegate?.mapView?(mapView, rendererForOverlay: overlay) ?? MKOverlayRenderer()
    }
    func mapView(mapView: MKMapView, didAddOverlayRenderers renderers: [MKOverlayRenderer]) {
        delegate?.mapView?(mapView, didAddOverlayRenderers: renderers)
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
    func resetRegion(region: MKCoordinateRegion) -> MKCoordinateRegion {
        var newRegion = region
        newRegion.span.latitudeDelta = minLatitudeDelta
        newRegion.span.longitudeDelta = minLongitudeDelta
        return newRegion
    }

}
