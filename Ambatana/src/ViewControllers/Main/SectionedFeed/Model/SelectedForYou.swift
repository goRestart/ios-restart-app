import IGListKit

final class SelectedForYou: ListDiffable {
    private let positionInFeed: Int
    
    init(positionInFeed: Int) {
        self.positionInFeed = positionInFeed
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "selected-for-you-\(positionInFeed)" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? SelectedForYou else  { return false }
        return positionInFeed == object.positionInFeed
    }
}
