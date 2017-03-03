extension Array {
    public func random() -> Element? {
        guard !isEmpty else { return nil }
        let idx = Int.makeRandom(min: 0, max: count-1)
        return self[idx]
    }
}

extension Array where Element: Randomizable {
    public static func makeRandom() -> Array<Element> {
        var array = Array<Element>()
        (0..<Int.makeRandom(min: 1, max: Int.makeRandom())).forEach { _ in array.append(Element.makeRandom()) }
        return array
    }
}
