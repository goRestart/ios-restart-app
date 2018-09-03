import IGListKit

final class LocationData: ListDiffable {
    let locationString: String
    
    init(locationString: String) {
        self.locationString = locationString
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "locationString-\(locationString)" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? LocationData else  { return false }
        return locationString == object.locationString
    }
}
