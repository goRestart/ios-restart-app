extension LGSize: MockFactory {
    public static func makeMock() -> LGSize {
        return LGSize(width: Float.makeRandom(),
                      height: Float.makeRandom())
    }
}
