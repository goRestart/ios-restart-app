extension Optional where Wrapped: MockFactory {
    public static func makeMock() -> Optional<Wrapped> {
        guard Int.makeRandom(min: 0, max: 9) == 0 else { return .none }
        return .some(Wrapped.makeMock())
    }
}
