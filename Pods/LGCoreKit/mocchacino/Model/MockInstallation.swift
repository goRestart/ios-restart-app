public struct MockInstallation: Installation {
    public var objectId: String?
    public var appIdentifier: String
    public var appVersion: String
    public var deviceType: String
    public var timeZone: String?
    public var localeIdentifier: String?
    public var deviceToken: String?

    public init(objectId: String?,
                appIdentifier: String,
                appVersion: String,
                deviceType: String,
                timeZone: String?,
                localeIdentifier: String?,
                deviceToken: String?) {
        self.objectId = objectId
        self.appIdentifier = appIdentifier
        self.appVersion = appVersion
        self.deviceType = deviceType
        self.timeZone = timeZone
        self.localeIdentifier = localeIdentifier
        self.deviceToken = deviceToken
    }
}
