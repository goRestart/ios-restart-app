import MapKit

extension MKMapView {
    // Create a unique isntance of MKMapView due to: http://stackoverflow.com/questions/36417350/mkmapview-using-a-lot-of-memory-each-time-i-load-its-view
    @nonobjc static let sharedInstance = MKMapView()
}

