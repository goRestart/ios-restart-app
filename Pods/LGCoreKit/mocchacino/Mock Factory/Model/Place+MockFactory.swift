extension Place: MockFactory {
    public static func makeMock() -> Place {
        return Place(postalAddress: PostalAddress?.makeMock(),
                     location: LGLocationCoordinates2D?.makeMock())
    }
}
