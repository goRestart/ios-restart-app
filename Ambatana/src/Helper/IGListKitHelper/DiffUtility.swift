import IGListKit

//: Take from A Discussion of IGListKit: How to use struct in diffable
// https://github.com/Instagram/IGListKit/issues/35#issuecomment-277503724

/**
 A diffable value type that can be used in conjunction with
 `DiffUtility` to perform a diff between two result sets.
 */
public protocol Diffable: Equatable {
    
    /**
     Returns a key that uniquely identifies the object.
     
     - returns: A key that can be used to uniquely identify the object.
     
     - note: Two objects may share the same identifier, but are not equal.
     
     - warning: This value should never be mutated.
     */
    var diffIdentifier: String { get }
}

/**
 Performs a diff operation between two sets of `ItemDiffable` results.
 */
public struct DiffUtility {
    
    public struct DiffResult {
        public typealias Move = (from: Int, to: Int)
        public let inserts: [Int]
        public let deletions: [Int]
        public let updates: [Int]
        public let moves: [Move]
        
        public let oldIndexForID: (_ id: String) -> Int
        public let newIndexForID: (_ id: String) -> Int
    }
    
    public static func diff<T: Diffable>(originalItems: [T], newItems: [T]) -> DiffResult {
        let old = originalItems.map({ DiffableBox(value: $0, identifier: $0.diffIdentifier as NSObjectProtocol, equal: ==) })
        let new = newItems.map({ DiffableBox(value: $0, identifier: $0.diffIdentifier as NSObjectProtocol, equal: ==) })
        let result = ListDiff(oldArray: old, newArray: new, option: .equality)
        
        let inserts = Array(result.inserts)
        let deletions = Array(result.deletes)
        let updates = Array(result.updates)
        
        let moves: [DiffResult.Move] = result.moves.map({ (from: $0.from, to: $0.to) })
        
        let oldIndexForID: (_ id: String) -> Int = { id in
            return result.oldIndex(forIdentifier: NSString(string: id))
        }
        let newIndexForID: (_ id: String) -> Int = { id in
            return result.newIndex(forIdentifier: NSString(string: id))
        }
        return DiffResult(inserts: inserts, deletions: deletions, updates: updates, moves: moves, oldIndexForID: oldIndexForID, newIndexForID: newIndexForID)
    }
}

final class DiffableBox<T: Diffable>: ListDiffable {
    
    let value: T
    let identifier: NSObjectProtocol
    let equal: (T, T) -> Bool
    
    init(value: T, identifier: NSObjectProtocol, equal: @escaping(T, T) -> Bool) {
        self.value = value
        self.identifier = identifier
        self.equal = equal
    }
    
    // IGListDiffable
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? DiffableBox<T> {
            return equal(value, other.value)
        }
        return false
    }
}

extension String: Diffable {
    public var diffIdentifier: String { return self }
}

extension Int: Diffable {
    public var diffIdentifier: String { return String(self) }
}

extension Sequence where Iterator.Element: Diffable {
    func listDiffable() -> [ListDiffable] {
        let toListDiffable: [ListDiffable] = map{ DiffableBox(value: $0, identifier: $0.diffIdentifier as NSObjectProtocol, equal: ==) }
        return toListDiffable
    }
}

extension Diffable {
    func listDiffable() -> ListDiffable {
        return DiffableBox(value: self,
                           identifier: self.diffIdentifier as NSObjectProtocol,
                           equal: ==)
    }
}
