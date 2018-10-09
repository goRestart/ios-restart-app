extension Collection where Element: Equatable {
    func index(for element: Element) -> Int? {
        guard let idx = self.index(of: element) else { return nil }
        return distance(from: startIndex, to: idx)
    }
}

extension Collection {
    func index(of element: Element, where predicate: ((Self.Element) -> Bool)) -> Int? {
        guard let idx = index(where: predicate) else { return nil }
        return distance(from: startIndex, to: idx)
    }
}
