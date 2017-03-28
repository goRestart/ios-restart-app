
extension MockInstallationRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockInstallationRepository = self.init()
        mockInstallationRepository.result = InstallationResult(value: MockInstallation.makeMock())
        return mockInstallationRepository
    }
}

