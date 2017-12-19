extension Double: Randomizable {
    public static func makeRandom() -> Double {
        let a = Double(Int.makeRandom())
        let b = Double(Int.makeRandom())
        return makeRandom(min: min(a, b), max: max(a, b))
    }
}

public extension Double {
    static func makeRandom(min: Double, max: Double) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}
