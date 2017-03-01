import Foundation

extension MockInstallation: MockFactory {
    public static func makeMock() -> MockInstallation {
        return MockInstallation(objectId: String.makeRandom(),
                                appIdentifier: String.makeRandom(),
                                appVersion: String.makeRandom(),
                                deviceType: String.makeRandom(),
                                timeZone: TimeZone.knownTimeZoneIdentifiers.random(),
                                localeIdentifier: Locale.availableIdentifiers.random(),
                                deviceToken: String.makeRandom())
    }

    static func makeMockWithActualDeviceId() -> MockInstallation {
        var installation = MockInstallation.makeMock()
        installation.objectId = InternalCore.deviceIdDAO.deviceId
        return installation
    }
}
