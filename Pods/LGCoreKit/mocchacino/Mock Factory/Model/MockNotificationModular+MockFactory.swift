extension MockNotificationModular: MockFactory {
    public static func makeMock() -> MockNotificationModular {
        return MockNotificationModular(text: MockNotificationTextModule.makeMock(),
                                       campaignType: String.makeRandom(),
                                       callToActions: MockNotificationCTAModule.makeMocks(count: Int.makeRandom(min: 1, max: 3)),
                                       basicImage: MockNotificationImageModule.makeMock(),
                                       iconImage: MockNotificationImageModule.makeMock(),
                                       heroImage: MockNotificationImageModule.makeMock(),
                                       thumbnails: MockNotificationImageModule.makeMocks(count: Int.makeRandom(min: 1, max: 3)))
    }
}
