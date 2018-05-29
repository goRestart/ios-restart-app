extension Array {
    public func random() -> Element? {
        guard !isEmpty else { return nil }
        let idx = Int.makeRandom(min: 0, max: count-1)
        return self[idx]
    }
}

extension Array where Element: Randomizable {
    public static func makeRandom(range: ClosedRange<Int> = 1...Int.makeRandom()) -> Array<Element> {
        var array = Array<Element>()
        (0..<Int.makeRandom(min: range.lowerBound, max: range.upperBound)).forEach { _ in array.append(Element.makeRandom()) }
        return array
    }
}
