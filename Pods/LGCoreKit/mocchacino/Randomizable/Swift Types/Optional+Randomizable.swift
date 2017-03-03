extension Optional where Wrapped: Randomizable {
    public static func makeRandom() -> Optional<Wrapped> {
        guard Int.makeRandom(min: 0, max: 9) == 0 else { return .none }
        return .some(Wrapped.makeRandom())
    }
}
