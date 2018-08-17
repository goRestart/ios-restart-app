
struct LGFeedLocation: Decodable {
    let longitude: Double
    let latitude: Double
}

extension LGFeedLocation {
    
    static func toLGLocationCoordinates2D(location: LGFeedLocation) -> LGLocationCoordinates2D {
        return LGLocationCoordinates2D(latitude: location.latitude, longitude: location.longitude)
    }
}
