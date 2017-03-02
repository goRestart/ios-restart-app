extension MockCommercializer: MockFactory {
    public static func makeMock() -> MockCommercializer {
        return MockCommercializer(objectId: String.makeRandom(),
                                  status: CommercializerStatus.makeMock(),
                                  videoHighURL: String?.makeRandom(),
                                  videoLowURL: String?.makeRandom(),
                                  thumbURL: String?.makeRandom(),
                                  shareURL: String?.makeRandom(),
                                  templateId: String?.makeRandom(),
                                  title: String?.makeRandom(),
                                  duration: Int?.makeRandom(),
                                  updatedAt: Date?.makeRandom(),
                                  createdAt: Date?.makeRandom())
    }
}
