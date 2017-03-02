extension Bool: Randomizable {
    public static func makeRandom() -> Bool {
        return Int.makeRandom(min: 0, max: 1) == 0
    }
}
