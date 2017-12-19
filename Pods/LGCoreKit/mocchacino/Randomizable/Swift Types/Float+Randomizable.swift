extension Float: Randomizable {
    public static func makeRandom() -> Float {
        let a = Float(Int.makeRandom())
        let b = Float(Int.makeRandom())
        return makeRandom(min: min(a, b), max: max(a, b))
    }
}

public extension Float {
    static func makeRandom(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}
