extension MockCommercializerTemplate: MockFactory {
    public static func makeMock() -> MockCommercializerTemplate {
        return MockCommercializerTemplate(objectId: String.makeRandom(),
                                          thumbURL: String.makeRandomURL(),
                                          title: String?.makeRandom(),
                                          duration: Int?.makeRandom(),
                                          countryCode: String?.makeRandom(),
                                          videoM3u8URL: String.makeRandomURL(),
                                          videoHighURL: String.makeRandomURL(),
                                          videoLowURL: String.makeRandomURL())
    }
}
