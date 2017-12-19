extension MockContact: MockFactory {
    public static func makeMock() -> MockContact {
        return MockContact(email: String.makeRandomEmail(),
                           title: String.makeRandom(),
                           message: String.makeRandomPhrase(words: Int.makeRandom(min: 1, max: 5)))
    }
}
