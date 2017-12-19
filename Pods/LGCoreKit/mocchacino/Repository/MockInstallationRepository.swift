import Result
import RxSwift

open class MockInstallationRepository: InstallationRepository {
    public var result: InstallationResult!
    public let installationVar = Variable<Installation?>(nil)


    // MARK: - Lifecycle

    required public init() {
        
    }


    // MARK: - InstallationRepository

    public var installation: Installation? {
        return installationVar.value
    }

    public var rx_installation: Observable<Installation?> {
        return installationVar.asObservable()
    }

    public func updatePushToken(_ token: String, completion: InstallationCompletion?) {
        delay(result: result, completion: completion)
    }
}
