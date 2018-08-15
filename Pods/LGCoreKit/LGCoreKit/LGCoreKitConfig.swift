public struct LGCoreKitConfig {
    
    public var environmentType: EnvironmentType
    public var carsInfoAppJSONURL: URL
    public var servicesInfoAppJSONURL: URL

    public init(environmentType: EnvironmentType,
                carsInfoAppJSONURL: URL,
                servicesInfoAppJSONURL: URL) {
        self.environmentType = environmentType
        self.carsInfoAppJSONURL = carsInfoAppJSONURL
        self.servicesInfoAppJSONURL = servicesInfoAppJSONURL
    }
}
