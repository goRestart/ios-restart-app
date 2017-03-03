extension Array where Element: MockFactory {
    public static func makeMocks(count: Int = Int.makeRandom()) -> Array {
        return Element.makeMocks(count: count)
    }
}
