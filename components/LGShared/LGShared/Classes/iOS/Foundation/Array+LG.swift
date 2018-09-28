public extension Array where Element == String {
    public var stringCommaSeparated: String? {
        guard !isEmpty else { return nil }
        return joined(separator: ",")
    }
}

public extension Array where Element == Int {
    public var stringCommaSeparated: String? {
        guard !isEmpty else { return nil }
        return compactMap { String($0) }.joined(separator: ",")
    }
    
    func offsetBounds(by value: Int) -> [Int] {
        let sortedSelf = sorted()
        return [sortedSelf.first.map({$0 - value}),
                sortedSelf.last.map({$0 + value})]
            .compactMap({$0}).sorted()
    }
}

public extension Array where Index == Int {
    func insert(newList list: [Element], at positions: [Int]) -> [Element] {
        guard !positions.isEmpty, !list.isEmpty else { return self }
        
        var mutatingList = self
        positions.enumerated().reversed().forEach { index, position in
            guard let newElement = list.element(at: index),
                mutatingList.count > position else { return }
            mutatingList.insert(newElement, at: position)
        }
        return mutatingList
    }
    
    private func element(at index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
