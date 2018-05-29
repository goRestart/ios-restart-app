extension ImageMultiplierParams: MockFactory {
    public static func makeMock() -> ImageMultiplierParams {
        return ImageMultiplierParams(imageId: String.makeRandom(), times: Int.makeRandom(min: 1, max: 100))
    }
}
