extension Dictionary {
    public func random() -> (Key, Value)? {
        guard !isEmpty else { return nil }

        let keysArr = Array(keys)
        let index = Int.makeRandom(min: 0, max: keysArr.count-1)
        let key = keysArr[index]
        return (key, self[key]!)
    }
}

extension Dictionary where Key: Randomizable, Value: Randomizable {
    public static func makeRandom() -> Dictionary<Key, Value> {
        var dict = Dictionary<Key, Value>()
        (0..<Int.makeRandom()).forEach { _ in dict[Key.makeRandom()] = Value.makeRandom() }
        return dict
    }
}
