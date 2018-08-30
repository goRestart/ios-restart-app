enum ListingRetrievalState: String, Diffable {
    
    case loading, error, lastPage
    
    var diffIdentifier: String {
        return "ListingRetrievalState-\(self.rawValue)"
    }
}
